
package Logicap

import chisel3._
import chisel3.util._


class AXISFifo(dataWidth: Int, depth: Int) extends Module{
  val io = IO(
    new Bundle {
      val slave_if = AXIStreamIO(AXIStreamInterfaceParams(dataWidth = dataWidth, hasTlast = false))
      val master_if = AXIStreamIO(AXIStreamInterfaceParams(dataWidth = dataWidth, hasTlast= true)).flipped()
    })
}
