# This is a fantastic example of how *not* to use Ghidra's
# emulator.
#
# The documentation is basically non-existent, so it was not obvious
# that the emulator keeps track of what's been modified by emulation
# in its own state, and the emulator does not interact nicely with
# direct modification to RAM as done below. Basically, this did not
# work.
#
# Note the hassle trying to pass word values to Ghidra because it
# believes shorts must be signed. *sigh*
#
# This was extremely hacky - to get a quick turnaround I kept C&Ping
# modifications into the Ghidra REPL, so this is not a plug-in.

e = ghidra.app.emulator.EmulatorHelper(currentProgram)
m = currentProgram.getMemory()
e.writeRegister("a0", 0x1BBF0)
e.writeRegister("pc", 0x01509c)
illegal_trap_vector = m.getInt(toAddr(0x10))
# Initialise the vector, as we'll check it.
# TODO: Not working?
m.setInt(toAddr(0x24), 0x1bb8c + 6)

# No native trace ability, fake it.
def trace():
    d6 = e.readRegister("d6")
    a6 = e.readRegister("a6")
    # Re-encrypt last instruction
    if (a6 < 0x80000) and (m.getInt(toAddr(0x24)) == 0x1bb8c) and 0:
        dea6 = (int(d6) ^ m.getInt(toAddr(a6))) & 0xffffffff
        if dea6 >= 0x80000000:
            dea6 -= 0x80000000
        m.setInt(toAddr(a6), dea6)
        dea64 = (int(d6) ^ m.getInt(toAddr(a6 + 4))) & 0xffffffff
        if dea64 >= 0x80000000:
            dea64 -= 0x80000000
        m.setInt(toAddr(a6 + 4), dea64)
    # Generate new key.
    d6_low = e.readRegister("sr") & 0xa71f
    old_d0 = e.readRegister("d0")
    new_d0 = (old_d0  & 0xffff0000) | ((old_d0 + d6) & 0xffff)
    e.writeRegister("d0", new_d0)
    old_d1 = e.readRegister("d1")
    new_d1 = (old_d1  & 0xffff0000) | ((old_d1 + d6) & 0xffff)
    e.writeRegister("d1", new_d1)
    d6 = (d6 & 0xffff0000) | d6_low
    d6 ^= e.readRegister("d1")
    d6 ^= e.readRegister("d2")
    e.writeRegister("d6", d6)
    # Decrypt next 4 bytes.
    a6 = e.readRegister("pc")
    e.writeRegister("a6", a6)
    printf("Hmmm. d6 = %12x a6 = %12x\n ", d6, a6)
    d6 = d6 & 0xfffffffff
    if d6 >= 0x80000000:
        d6 -= 0x80000000
    m.setInt(toAddr(a6), d6 ^ m.getInt(toAddr(a6)))
    m.setInt(toAddr(a6 + 4), d6 ^ m.getInt(toAddr(a6 + 4)))
    # And the icing on the cake
    global illegal_trap_vector
    illegal_trap_vector += d6

def step():
    tracing = e.readRegister("sr") & 0x8000
    ret = e.step(monitor)
    if not ret:
        printf("Err: %s\n", e.getLastError())
    if tracing:
        trace()
    pc = e.readRegister("pc")
    printf("PC=%08x (PC)=%08x %08x %08x\n", pc, m.getInt(toAddr(pc)), m.getInt(toAddr(pc + 4)), m.getInt(toAddr(pc + 8)))

# This time, fake an exception?!
def step2():
    tracing = e.readRegister("sr") & 0x8000
    ret = e.step(monitor)
    if not ret:
        printf("Err: %s\n", e.getLastError())
    if tracing:
        pc = e.readRegister("pc")
        printf("PT PC=%08x (PC)=%08x %08x %08x\n", pc, m.getInt(toAddr(pc)), m.getInt(toAddr(pc + 4)), m.getInt(toAddr(pc + 8)))       
        printf("PT A6=%08x D6=%08x\n", e.readRegister("a6"), e.readRegister("d6"))
        sp = e.readRegister("sp") - 4
        m.setInt(toAddr(sp), e.readRegister("pc"))
        sp -= 2
        sr = e.readRegister("sr") & 0xffff
        if sr >= 0x8000:
            sr -= 0x8000
        m.setShort(toAddr(sp), sr)
        e.writeRegister("sp", sp)
        # Diable trace during trace!
        e.writeRegister("sr", sr & 0x7fff)
        e.writeRegister("pc", m.getInt(toAddr(0x24)))
    pc = e.readRegister("pc")
    printf("PC=%08x (PC)=%08x %08x %08x\n", pc, m.getInt(toAddr(pc)), m.getInt(toAddr(pc + 4)), m.getInt(toAddr(pc + 8)))       
    printf("A6=%08x D6=%08x\n", e.readRegister("a6"), e.readRegister("d6"))
