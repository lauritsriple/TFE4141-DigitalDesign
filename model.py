def getBitAt(a, n):
        if n >= 0 and (a & (1 << (n))) != 0:
                return 1
        else:
                return 0
def monPro(A,B,n):
        M = 0
        for i in range(128):
            if getBitAt(B,i):
                M = M + A
            if getBitAt(M,0):
                M = M+n
            M=M>>1
        if M>=n:
            M=M-n
        return M

#http://waset.org/publications/7276/fpga-implementation-of-rsa-cryptosystem
def modExp2(m,e,n):
        k=128
        Y=(2**(2*k))%n
        print("Y:",hex(Y))
        #Y=0x819dc6b2819dc6b2819dc6b2819dc6b2
        P=monPro(Y,m,n)
        R=monPro(Y,1,n)
        for i in range(k-1, -1, -1):
                R = monPro(R,R, n)
                if getBitAt(e,i):
                        R = monPro(P, R, n)
        R = monPro(1, R, n)
        return R

def main():
        print("MODEXP",hex(modExp2(0x0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,0x00000000000000000000000000010001,0x819DC6B2574E12C3C8BC49CDD79555FD)))

if __name__ == "__main__":
    main()
