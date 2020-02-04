package Logicap

import chisel3._
import chisel3.util._

class TriggerConfiguration(levelCount: Int, logicWidth: Int) extends Bundle {
  val masks = Vec(levelCount, UInt(logicWidth.W))
  val levels = Vec(levelCount, UInt(logicWidth.W))
  val types = Vec(levelCount, UInt(logicWidth.W))
  // why can't it figure out?
  override def cloneType = (new TriggerConfiguration(levelCount, logicWidth)).asInstanceOf[this.type]
}

class TriggerControl extends Bundle {
  val arm = Input(Bool())
  val abort = Input(Bool())
  val ignore = Input(Bool())
  val triggered = Output(Bool())
  val armed = Output(Bool())
}

class TriggerLogic(levelCount: Int = 8, logicWidth: Int = 32) extends Module {
  val io = IO(
    new Bundle {
      val control = new TriggerControl
      val dinput = Input(UInt(logicWidth.W))
      val config = Input(new TriggerConfiguration(levelCount, logicWidth))
      val sampleClk = Input(Clock())
    })

  // configurations
  val trigMasks = RegInit(VecInit(Seq.fill(levelCount)(0.U(logicWidth.W))))
  val trigLevels = RegInit(VecInit(Seq.fill(levelCount)(0.U(logicWidth.W))))
  val trigTypes = RegInit(VecInit(Seq.fill(levelCount)(0.U(logicWidth.W))))

  val isArmed = RegInit(false.B)
  val isTriggered = RegInit(false.B)
  io.control.armed := isArmed
  io.control.triggered := isTriggered

  val triggerLevel = RegInit(0.U(log2Up(levelCount).W))

  // consts
  private val TriggerLevel = 0.U
  private val TriggerEdge = 1.U
  private val TriggerRise = 1.U
  private val TriggerFall = 0.U

  // trigger conditions
  val triggerCondition = RegInit(VecInit(Seq.fill(logicWidth)(false.B)))
  val currentMasked = Wire(UInt(logicWidth.W))
  currentMasked := trigMasks(triggerLevel) & io.dinput

  // save inputs from this clock cycle (clocked by sampleClk)
  withClock(io.sampleClk) {
    val oldInputs = RegInit(0.U(logicWidth.W))
    when (!io.control.ignore) {
      oldInputs := io.dinput
    }

    // generate trigger conditions
    for (i <- 0 to logicWidth-1) {
      when (isArmed && !io.control.ignore) {
        when (currentMasked(i)) {
          when (trigTypes(triggerLevel)(i) === TriggerLevel) {
            when (trigLevels(triggerLevel)(i) === io.dinput(i)) {
              triggerCondition(i) := true.B
            }.otherwise {
              triggerCondition(i) := false.B
            }
          }.otherwise {
            // edge
            when (trigLevels(triggerLevel)(i) === TriggerRise) {
              when (oldInputs(i) === 0.U && io.dinput(i) === 1.U) {
                triggerCondition(i) := true.B
              }.otherwise {
                triggerCondition(i) := false.B
              }
            }.otherwise {
              when (oldInputs(i) === 1.U && io.dinput(i) === 0.U) {
                triggerCondition(i) := true.B
              }.otherwise {
                triggerCondition(i) := false.B
              }
            }
          }
        }.otherwise {
          triggerCondition(i) := false.B
        }
      }.otherwise {
        triggerCondition(i) := false.B
      }
    }
  }

  // overall trigger logic
  when (isArmed && !io.control.ignore) {
    when (io.control.abort) {
      isArmed := false.B
      triggerLevel := 0.U
    }.otherwise {
      when (!trigMasks(triggerLevel)) {
        // unconfigured trigger, done
        isArmed := false.B
        isTriggered := true.B
      }.otherwise {
        when (triggerCondition.asUInt === trigMasks(triggerLevel)) {
          when (triggerLevel < (levelCount - 1).U) {
            triggerLevel := triggerLevel + 1.U
          }.otherwise {
            isArmed := false.B
            isTriggered := true.B
            triggerLevel := 0.U
          }
        }
      }
    }
  }.otherwise {
    when (io.control.arm) {
      isArmed := true.B
      isTriggered := false.B
      triggerLevel := 0.U
      // LOAD CONFIGURATION HERE
      trigLevels := io.config.levels
      trigMasks := io.config.masks
      trigTypes := io.config.types
    }
  }

}

object TriggerDriver extends App {
  chisel3.Driver.execute(args, () => new TriggerLogic())
}
