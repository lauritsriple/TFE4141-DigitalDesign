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
                #print("m+a",M)
                if getBitAt(M,0):
                    M = M+n
                M=M>>1
                #print("m+n",M)
        #if M>=n:
        #    print("Wow, this actually happend")
        #    M=M-n
        return M

#http://waset.org/publications/7276/fpga-implementation-of-rsa-cryptosystem
def modExp2(m,e,n,r):
        k=128
        Y=(2**(2*k))%n
        m_=monPro(Y,m,n)
        x_=monPro(Y,1,n)
        #m_ = (m*2**128)%n
        #x_ = (2**128)%n
        for i in range(k-1, -1, -1):
                x_ = monPro(x_,x_, n)
                if getBitAt(e,i):
                        x_ = monPro(m_, x_, n)
        x_ = monPro(1, x_, n)
        return x_


def modExp(m,e,n,r):
        k=128
        m_ = (m*2**128)%n
        x_ = (2**128)%n
        for i in range(k-1, -1, -1):
                x_ = monPro(x_, x_, n)
                if getBitAt(e,i):
                        x_ = monPro(m_, x_, n)
        x_ = monPro(x_, 1, n)
        return x_

def main():
        #print("RES monpro",monPro(7,7,11))
        #print("Example",monPro(3,3,13))
        #print("calc",(7**10)%13)
        print("Modexp",modExp(7,10,13,16))
        print("Modexp2",modExp2(7,10,13,16))
        #print("Modexp2",hex(modExp(0x0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,0x00000000000000000000000000010001,0x819DC6B2574E12C3C8BC49CDD79555FD,0x100000000000000000000000000000000)))
        #M_calculations(3,123)

if __name__ == "__main__":
    main()
