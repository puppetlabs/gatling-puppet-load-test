package com.puppetlabs.json

class ClassCast[T] { def unapply(a:Any):Option[T] = Some(a.asInstanceOf[T])}

object JsonMap extends ClassCast[Map[String, Any]]
object JsonList extends ClassCast[List[Any]]
object JsonString extends ClassCast[String]

object JsonInt {
  def unapply(a:Any):Option[Int] = Some(a.asInstanceOf[Double].toInt)
}
