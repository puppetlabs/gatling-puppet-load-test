/**
 * This package just contains some utils that make it easier
 * to extract data from a JSON file via pattern matching.
 */
package com.puppetlabs.json

// allows us to pattern match on any Type T
class ClassCast[T] { def unapply(a:Any):Option[T] = Some(a.asInstanceOf[T])}

object JsonMap extends ClassCast[Map[String, Any]]
object JsonList extends ClassCast[List[Any]]
object JsonString extends ClassCast[String]
object JsonBool extends ClassCast[Boolean]

// Scala's JSON parser parses all numeric values as Doubles, so
// we need to explicitly convert if we actually want an Int.
object JsonInt {
  def unapply(a:Any):Option[Int] = Some(a.asInstanceOf[Double].toInt)
}
