name := "pyspark-cassandra"

version := "0.1.5"

organization := "TargetHolding"

scalaVersion := "2.10.4"

credentials += Credentials(Path.userHome / ".ivy2" / ".sbtcredentials")

licenses += "Apache-2.0" -> url("http://opensource.org/licenses/Apache-2.0")

libraryDependencies ++= Seq(
	"com.datastax.spark" %% "spark-cassandra-connector-java" % "1.2.5"
)

spName := "TargetHolding/pyspark-cassandra"

sparkVersion := "1.3.1"

sparkComponents += "streaming"

javacOptions ++= Seq("-source", "1.7", "-target", "1.7")
