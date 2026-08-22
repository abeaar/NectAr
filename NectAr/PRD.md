## 1. Summary

An iOS augmented-reality app that makes an invisible network topology visible in the
user's own room. The user places three physical-looking markers — **Device A**, a
**Router**, and **Device B** — on real surfaces detected by ARKit, then taps **Send
Ping**. A packet travels A → Router → B and back along the drawn links, slowly enough
that the user can walk alongside it, and the app reports a plausible round-trip time.

The point is pedagogy, not measurement: the app teaches that traffic between two
devices does not go device-to-device but hops through infrastructure, and that this
hop takes real time — just ~1000× less than the animation shows.

## 2. Problem

Networking is taught with diagrams on a page. Learners hold a mental model where
"my laptop talks to that printer" is a straight line, and where latency is an
abstract number in a terminal. Two ideas are consistently hard to convey:

1. **Traffic is routed, not direct.** There is a middlebox in the path, and it is a
   real object sitting on a real shelf in the room.
2. **Latency is a distance-and-hops phenomenon.** `time=8ms` means nothing until you
   watch something physically cover the path twice.

Nothing available puts the topology at 1:1 scale in the room the learner is standing
in, anchored to their actual router.

## 3. Goals & non-goals

### Goals
- **G1** — A user can place a three-node topology on real surfaces in under 60 seconds
  with no instructions beyond the on-screen hint.
- **G2** — The round trip is legible: the user can tell, without narration, that the
  packet passed *through* the router in both directions and that the reply is a
  distinct thing from the request.
- **G3** — The router can be **wall-mounted**, because that is where routers live.
  Clients stay on horizontal surfaces.
- **G4** — When AR tracking fails to find a surface, the user is told *why*, not just
  that it failed.
- **G5** — The AR layer stays isolated behind a protocol so the UI is testable and the
  simulation is replaceable.

### Non-goals (this release)
- Real network measurement (no ICMP, no interface enumeration, no local-network
  permission). The RTT is illustrative.
- More than three nodes, or arbitrary topologies (switches, mesh, WAN/internet leg).
- Persistence of a placed topology across launches or ARWorldMap sharing.
- Multi-user / shared AR sessions.
- Android, visionOS, or macOS.

## 4. Target users

| Persona | Need | How the app serves it |
|---|---|---|

| **Self-taught learner** | Intuition for "why does my ping go up when I move rooms" | Places the router where their real router is, walks with the packet |
