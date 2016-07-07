# ProtocolBuffersCompiler
A Encoder/Decoder written in Swift for Google Protocol Buffers

Usage is simple, there are 2 types `Key` and `Value`. Value contains the value of type `Any` and the `Key` for decoding/encoding.

`Encoder` ( singleton available under `shared` ) and `Decoder` are used respectively to either generate a NSData stream or decode one into a [FieldNumber: Value] collection.

The Encoder only accepts an array of Values as the Key instance within them will contain the correct fieldNumber, since ordering is not important an array is used for faster writing your boiler plate code.


