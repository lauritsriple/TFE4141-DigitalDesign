def RSA(key1, mod, mes):
    return ((mes**(key1)) % mod)

def monPro(a,b, n_marked, r, n):
	t = a*b
	m = t*n_marked%r
	u = (t+m*n)//r
#	print("Monpro:", a, b)
	if u >= n:
#		print("Monproresult:", u-n)
		return u-n
	else:
#		print("Monproresult:", u)
		return u
	
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
	print(modExp(7,10,13))

if __name__ == "__main__":
    main()
