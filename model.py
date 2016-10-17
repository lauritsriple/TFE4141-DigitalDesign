# def monPro(A,B,m):
    # D = 0
    # for i in range(128):
		# if (i < B.bit_length()):
			# D = D + A*int(bin(B)[2::][-i-1])
		# D = (D + (D%2)*m) >> 1
    # return D
	
def monPro(A,B,n):
	M = 0
	
	for i in range(128):
		print(M)
		if (i < B.bit_length()):
			print("hei")
			M = M + (A*int(bin(B)[2::][-i-1]))
		if (M%2):
			M = M >> 1
		else:
			M = (M+n) >> 1
	return M

# def monExp(P,e,m):
    # K = 2**(2*m) % m
    # Z = monPro(1,K,m)
    # P = monPro(P,K,m)
    # k = len(bin(e))-2
    # for i in range(k):
        # if (int(bin(e)[-i-1])):
            # Z = monPro(Z,P,m)
        # P = monPro(P,P,m)
    # Z = monPro(1,Z,m)
    # return Z

# def monPro(a,b, n_marked, r, n):
	# t = a*b
	# m = t*n_marked%r
	# u = (t+m*n)//r
# #	print("Monpro:", a, b)
	# if u >= n:
# #		print("Monproresult:", u-n)
		# return u-n
	# else:
# #		print("Monproresult:", u)
		# return u
	
def modExp(a,b,n):
	k = n.bit_length()
	r = 2**(k)
	#Calculate r_marked
	i = 1
	while (r*i%n != 1):
		i+=1
	r_marked = i
	
	#Calculate n_marked
	n_marked = int((r*r_marked -1)/n)
	
	a_hat = a*r%n
	x_hat = r%n
	for i in range(k-1, -1, -1):
		x_hat = monPro(x_hat, x_hat, n_marked, r, n)
		if (int(bin(b)[-i-1])):
			x_hat = monPro(a_hat, x_hat, n_marked, r, n)
	x = monPro(x_hat, 1, n_marked, r, n)
	return r_marked, n_marked, a_hat, x_hat, x
	
def main():
	print("RES monpro",monPro(7,7,11))
	print("calc",(7*7)%11)
#	print(modExp(7,10,13))

if __name__ == "__main__":
    main()
