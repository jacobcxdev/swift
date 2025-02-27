//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import _Distributed


// ==== Fake Transport ---------------------------------------------------------

struct ActorAddress: Hashable, Sendable, Codable {
  let address: String
  init(parse address : String) {
    self.address = address
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.address = try container.decode(String.self)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.address)
  }
}

final class FakeActorSystem: DistributedActorSystem {
  typealias ActorID = ActorAddress
  typealias InvocationDecoder = FakeInvocation
  typealias InvocationEncoder = FakeInvocation
  typealias SerializationRequirement = Codable

  func resolve<Act>(id: ActorID, as actorType: Act.Type) throws -> Act?
      where Act: DistributedActor,
      Act.ID == ActorID  {
    return nil
  }

  func assignID<Act>(_ actorType: Act.Type) -> ActorID
      where Act: DistributedActor,
      Act.ID == ActorID {
    ActorAddress(parse: "fake://\(actorType)")
  }

  func actorReady<Act>(_ actor: Act)
      where Act: DistributedActor,
      Act.ID == ActorID {
  }

  func resignID(_ id: ActorID) {
  }

  func makeInvocationEncoder() -> InvocationEncoder {
    .init()
  }

  func remoteCall<Act, Err, Res>(
      on actor: Act,
      target: RemoteCallTarget,
      invocation: InvocationDecoder,
      throwing: Err.Type,
      returning: Res.Type
  ) async throws -> Res
      where Act: DistributedActor,
            Act.ID == ActorID,
            Res: SerializationRequirement {
    throw FakeDistributedSystemError(message: "mock impl")
  }
}

struct FakeDistributedSystemError: DistributedActorSystemError {
  let message: String
}

class FakeInvocation: DistributedTargetInvocationEncoder, DistributedTargetInvocationDecoder {
  typealias SerializationRequirement = Codable

  func recordGenericSubstitution<T>(_ type: T.Type) throws {}
  func recordArgument<Argument: SerializationRequirement>(_ argument: Argument) throws {}
  func recordReturnType<R: SerializationRequirement>(_ type: R.Type) throws {}
  func recordErrorType<E: Error>(_ type: E.Type) throws {}
  func doneRecording() throws {}

  // === Receiving / decoding -------------------------------------------------

  func decodeGenericSubstitutions() throws -> [Any.Type] { [] }
  func decodeNextArgument<Argument>() throws -> Argument { fatalError() }
  func decodeReturnType() throws -> Any.Type? { nil }
  func decodeErrorType() throws -> Any.Type? { nil }
}

@available(SwiftStdlib 5.5, *)
typealias DefaultDistributedActorSystem = FakeActorSystem

// ==== ------------------------------------------------------------------------

distributed actor DA {
  typealias ActorSystem = FakeActorSystem

  distributed func hello(other: DA) {}
}

