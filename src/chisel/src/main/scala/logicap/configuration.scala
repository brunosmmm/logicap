package Logicap

package object LogicapConfiguration {
  val LogicWidth: Int = 32
  val TriggerLevels: Int = 8
  val MaxClkDiv: Int = 32
  val MaxSampleCount: Int = 4*1024*1024 // 4 Mega samples
  val AXIStreamWidth: Int = 64
  val AXIStreamDefaultParams = new AXIStreamInterfaceParams(dataWidth=AXIStreamWidth, hasTlast=true)
}
