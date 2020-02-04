package Logicap

import chisel3._
import chisel3.util._

/** Clock divider; divides main clock by factor **/
class ClockDivider(maxClkDiv: Int = 32) extends Module {
  val io = IO(
    new Bundle {
      val clkOut = Output(Clock())
      val clkDiv = Input(UInt(log2Up(maxClkDiv).W))
      val inhibit = Input(Bool())
    })

  // clock divider
  val _clkDiv = RegInit(0.U(log2Up(maxClkDiv).W))
  val clkCounter = RegInit(0.U(log2Up(maxClkDiv).W))
  val clkSig = RegInit(false.B)
  io.clkOut := clkSig

  when (io.inhibit) {
    // restart divider
    clkCounter := 0.U
    clkSig := false.B
    _clkDiv := io.clkDiv
  }.otherwise {
    when (clkCounter < _clkDiv) {
      clkCounter := clkCounter + 1.U
    }.otherwise {
      clkSig := !clkSig
    }
  }
}

/** Logic capture core **/
class LogicCapture(maxClkDiv: Int = LogicapConfiguration.MaxClkDiv,
                   logicWidth: Int = LogicapConfiguration.LogicWidth,
                   triggerLevels: Int = LogicapConfiguration.TriggerLevels) extends Module {
  val io = IO(
    new Bundle {
      val sampleClk = Output(Clock())
      val logicInput = Input(UInt(logicWidth.W))
      val axiSMaster = Flipped(new AXIStreamIO(LogicapConfiguration.AXIStreamDefaultParams))
    })

  // placeholder stuff - will come from MM slave
  val masterEnable = Wire(Bool())
  val armRequest = Wire(Bool())
  val abortRequest = Wire(Bool())

  // clock divider
  val clkDiv = Wire(UInt(log2Up(maxClkDiv).W))    // clock divider value, comes from MM slave
  val ckdiv = Module(new ClockDivider(maxClkDiv))
  val ckdivEn = RegInit(false.B)
  ckdiv.io.inhibit := !ckdivEn
  ckdiv.io.clkDiv := clkDiv

  // trigger logic module
  val isArmed = Wire(Bool())
  val isTriggered = Wire(Bool())
  val trigger = Module(new TriggerLogic(logicWidth=logicWidth, levelCount=triggerLevels))
  trigger.io.sampleClk := ckdiv.io.clkOut
  trigger.io.dinput := io.logicInput
  trigger.io.control.ignore := !io.axiSMaster.tready
  trigger.io.control.abort := abortRequest
  isArmed := trigger.io.control.armed
  isTriggered := trigger.io.control.triggered

  withClock(io.sampleClk) {
    // DMA can be freeruning?
    val axiValid = Wire(Bool())
    val softOverrun = RegInit(false.B)
    val statusVector = Wire(UInt(6.W))
    val reachedPreTarget = RegInit(false.B) // we have minimum sample # pre-trigger
    val reachedPostTarget = RegInit(false.B) // we have sample # post trigger AKA done
    statusVector := Cat(reachedPostTarget, reachedPreTarget, softOverrun, armRequest, isArmed, isTriggered)
    axiValid := io.axiSMaster.tready && masterEnable && !reachedPostTarget
    io.axiSMaster.tdata := Cat(statusVector, 0.U((LogicapConfiguration.AXIStreamWidth - 6).W), io.logicInput)
    // FIXME: this looks pretty bad, is this the right way?
    io.axiSMaster.tlast match {
      case Some(p: Data) =>
        p := true.B
    }
    // io.axiSMaster.tlast := true.B
    io.axiSMaster.tvalid := axiValid

    // flag last sample as ignored if it was the case
    when (!io.axiSMaster.tready && masterEnable) {
      softOverrun := true.B
    }.otherwise {
      softOverrun := false.B
    }

    // calculate and track desired number of samples pre/post trigger
    val preTriggerCount = RegInit(0.U(log2Up(LogicapConfiguration.MaxSampleCount)))
    val preTriggerTarget = RegInit(0.U(log2Up(LogicapConfiguration.MaxSampleCount)))
    val postTriggerCount = RegInit(0.U(log2Up(LogicapConfiguration.MaxSampleCount)))
    val postTriggerTarget = Wire(UInt(log2Up(LogicapConfiguration.MaxSampleCount).W))
    // calculate post trigger sample count
    postTriggerTarget := LogicapConfiguration.MaxSampleCount.U - preTriggerTarget

    // count number of pre-trigger samples
    // FIXME: logic contradicts logic for TVALID, which makes the capture unit "free-running"
    when (masterEnable && isArmed && !isTriggered) {
      when (preTriggerCount < preTriggerTarget) {
        when (preTriggerCount === preTriggerTarget - 1.U) {
          reachedPreTarget := true.B
        }
        preTriggerCount := preTriggerCount + 1.U
      }
    }

    // count number of post-trigger samples
    when (masterEnable && isTriggered) {
      when (postTriggerCount < postTriggerTarget) {
        when (postTriggerCount === postTriggerTarget - 1.U) {
          reachedPostTarget := true.B
        }
        postTriggerCount := postTriggerCount + 1.U
      }
    }

    // on arm request, reset counters
    when (armRequest) {
      preTriggerCount := 0.U
      reachedPreTarget := false.B
      postTriggerCount := 0.U
      reachedPostTarget := false.B
      softOverrun := false.B
    }
  }

  // TODO: if I write a DMA driver, can I inspect incoming data and determine when to stop DMA?

}
