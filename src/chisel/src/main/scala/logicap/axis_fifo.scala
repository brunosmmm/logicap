package Logicap

import chisel3._
import chisel3.util._

// have to use AsyncQueue library to cross clock domains!
class AXISFifo(dataWidth: Int, depth: Int) extends Module{
  val io = IO(
    new Bundle {
      val slave_if = IO(new AXIStreamIO(AXIStreamInterfaceParams(dataWidth = dataWidth, hasTlast = false)))
      val master_if = IO(Flipped(new AXIStreamIO(AXIStreamInterfaceParams(dataWidth = dataWidth, hasTlast = true))))
      val slave_clock = Input(Clock())
      val master_clock = Input(Clock())
    })
}
