
def RSA(key1, mod, mes):
    return ((mes**(key1)) % mod)

def monPro(A,B,m):
    # D = 0
    # k = len(bin(B))-2
    # for i in range(k):
    #     D = D + A*int(bin(B)[-i-1])
    #     D = (D + (D%2)*m) >> 1
    return (A*B)%m

def monExp(P,e,m):
    K = 2**(2m) % m
    Z = monPro(1,K,m)
    P = monPro(P,K,m)
    k = len(bin(e))-2
    for i in range(k):
        if (int(bin(e)[-i-1])):
            Z = monPro(Z,P,m)
        P = monPro(P,P,m)
    Z = monPro(1,Z,m)
    return Z

def main():
    print(monExp(19, 5, 119))    # print("4:")
    # print(monPro(8,8,16))
    # print("1:")
    # print(monPro(4,4,16))
    # print("7:")
    # print(monPro(77,39,14))


if __name__ == "__main__":
    main()

# MonPro(A,B,m)=A*B*r^-1*mod(m)

# D = (A*B) mod m
# D = 0
# From i= 0 to i = k-1
# a. D = D + A*B_i
# b. D = (D+ D(0)*m)/2
#   3. Output D 	
