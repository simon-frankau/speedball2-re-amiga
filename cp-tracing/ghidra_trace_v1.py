#Emulate the trace-driven obfuscation in Speedball II.
#@author Simon Frankau
#@category _NEW_
#@keybinding 
#@menupath 
#@toolbar 

# This is a Ghidra-plugin attempt at emulating the trace. This time, I
# tried to apply all updates through the emulator, so that I could
# avoid fighting between the main memory and emulator views of what's
# in memory. It worked much better up to the point where I realised
# Ghidra's emulation was buggy, and maybe I should be using something
# more battle-tested!

import struct

class Tracer:
    def reset(self):
        self.e = ghidra.app.emulator.EmulatorHelper(currentProgram)
        self.e.enableMemoryWriteTracking(True)
        self.e.writeRegister("a0", 0x1BBEE)
        self.e.writeRegister("pc", 0x01509c)
        # self.illegal_trap_vector = m.getInt(toAddr(0x10))
        # Initialise the vector, as we'll check it.
        # TODO: Not working?
        # m.setInt(toAddr(0x24), 0x1bb8c + 6)

    def wordify(self, x):
        x = x & 0xffff
        # if x >= 0x8000:
        #    x -= 0x8000
        return x

    def read_long(self, addr):
        # return int.from_bytes(self.e.readMemory(toAddr(addr), 4))
        return struct.unpack(">I", self.e.readMemory(toAddr(addr), 4))[0]

    def read_short(self, addr):
        # return int.from_bytes(self.e.readMemory(toAddr(addr), 2))
        return struct.unpack(">H", self.e.readMemory(toAddr(addr), 2))[0]

    def read_byte(self, addr):
        return self.e.readMemoryByte(toAddr(addr))

    def step(self):
        # Manually handle RTE. :(
        if self.read_short(self.e.readRegister("pc")) == 0x4e73:
            printf("RTE!" )
            # Pop SR
            self.e.writeRegister("sr", self.e.readStackValue(0, 2, 0))
            self.e.writeRegister("sp", self.e.readRegister("sp") + 2)
            # Pop PC
            self.e.writeRegister("pc", self.e.readStackValue(0, 4, 0))
            self.e.writeRegister("sp", self.e.readRegister("sp") + 4)

            self.blurb()
            return

        # Manually handling A-line. :(
        if self.read_short(self.e.readRegister("pc")) & 0xf000 == 0xa000:
            printf("A-line! ")
            self.exception(0x28)
            self.blurb()
            return

        # Manually handling illegals. :(
        if self.read_byte(self.e.readRegister("pc")) == 0x4f:
            printf("Illegal!")
            self.exception(0x10)
            self.blurb()
            return
        
        tracing = self.e.readRegister("sr") & 0x8000
        ret = self.e.step(monitor)
        if not ret:
            printf("Err: %s\n", self.e.getLastError())
            return
        # for addrSet in self.e.trackedMemoryWriteSet:
        #     printf("??? %s ", addrSet)
        # printf("\n")
        if tracing:
            # pc = self.e.readRegister("pc")
            # printf("PT A6=%08x D6=%08x\n", self.e.readRegister("a6"), self.e.readRegister("d6"))
            self.exception(0x24)
            # Diable trace during trace!
            self.e.writeRegister("sr", self.e.readRegister("sr") & 0x7fff)
        self.blurb()

    def exception(self, vector):
        # Push PC
        self.e.writeRegister("sp", self.e.readRegister("sp") - 4)
        self.e.writeStackValue(0, 4, self.e.readRegister("pc"))
        # Push SR
        self.e.writeRegister("sp", self.e.readRegister("sp") - 2)
        self.e.writeStackValue(0, 2, self.wordify(self.e.readRegister("sr")))
        # Disable trace
        self.e.writeRegister("sr", self.e.readRegister("sr") & 0x7fff)
        # And jump to vector
        self.e.writeRegister("pc", self.read_long(vector))

    def blurb(self):
        # printf("PC=%08x (PC)=%08x %08x %08x\n", pc, self.read_long(pc), self.read_long(pc + 4), self.read_long(pc + 8))
        # printf("A6=%08x D6=%08x\n", self.e.readRegister("a6"), self.e.readRegister("d6"))
        pc = self.e.readRegister("pc")
        printf("PC=%08x (PC)=%08x %08x %08x\n", pc, self.read_long(pc), self.read_long(pc + 4), self.read_long(pc + 8))
        printf("A6=%08x D6=%08x D0=%08x D1=%08x D2=%08x\n", self.e.readRegister("a6"), self.e.readRegister("d6"), self.e.readRegister("d0"), self.e.readRegister("d1"), self.e.readRegister("d2"))
        
    def steps(self):
        for i in range(100):
            self.step()
        
t = Tracer()
t.reset()
t.steps()
