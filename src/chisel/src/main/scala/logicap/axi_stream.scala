package Logicap

import chisel3._
import chisel3.util._

/** AXI Stream interface parameters **/
case class AXIStreamInterfaceParams(dataWidth: Int, hasTlast: Boolean = false, tuserWidth: Int = 0)


/** AXI Stream IO **/
class AXIStreamIO(params: AXIStreamInterfaceParams) extends Bundle {
  val tdata = Input(UInt(params.dataWidth.W))
  val tvalid = Input(Bool())
  val tready = Output(Bool())
  val tlast = if (params.hasTlast) Some(Input(Bool())) else None
  val tuser = if (params.tuserWidth > 0) Some(Input(Bits(params.tuserWidth.W))) else None
}
