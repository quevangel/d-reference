// modular {{{
struct Z(immutable long m)
{
	long rep;
	static immutable bool primeModulus = isPrime(m);
	static Z!m[] fact;
	static if (primeModulus) { static Z!m[] invFact; }
	static makeFactorials(long n)
	{
		fact = new Z!m[](n + 1);
		fact[0] = Z!m(1);
		foreach(i; 1 .. n + 1) fact[i] = Z!m(i) * fact[i - 1];
		static if (primeModulus)
		{
			invFact = new Z!m[](n + 1);
			invFact[n] = fact[n].inv;
			foreach_reverse(i; 0 .. n) invFact[i] = Z!m(i + 1) * invFact[i + 1];
		}
	}

	this(long num)
	{
		rep = num;
	}

	Z!m opBinary(string operator)(Z!m rhs)
	{
		static if (operator == "+")
		{
			long result = rhs.rep + this.rep;
			if (result >= m)
				result -= m;
			return Z!m(result);
		}
		else static if (operator == "-")
		{
			long result = this.rep - rhs.rep;
			if (result < 0)
				result += m;
			return Z!m(result);
		}
		else static if (operator == "*")
		{
			long result = this.rep * rhs.rep;
			if (result >= m)
				result %= m;
			return Z!m(result);
		}
		else static if (operator == "/" && primeModulus)
		{
			assert(rhs != Z!m(0));
			return this * rhs.inv;
		}
		else
		{
			static assert(text("Operator ", operator, " not supported"));
		}
	}

	Z!m opBinary(string operator)(long exponent) if (operator == "^^")
	{
		assert(exponent >= 0);
		Z!m base = this;
		Z!m result = 1;
		while (exponent)
		{
			if (exponent & 1)
				result = result * base;
			base = base * base;
			exponent >>= 1;
		}
		return result;
	}

	static if (primeModulus)
	{
		Z!m inv()
		{
			return this^^(m - 2);
		}
		static Z!m C(int n, int k)
		{
			if (k < 0 || k > n) return Z!m(0);
			return fact[n] * invFact[k] * invFact[n - k];
		}
	}

	invariant
	{
		assert(rep >= 0 && rep < m);
	}
}
bool isPrime(long n)
{
	for(long d = 2; d * d <= n; d++)
		if (n % d == 0) return false;
	return true; 
}
unittest
{
	alias Zp = Z!23;
	static assert(Zp.primeModulus);
	foreach(i; 1 .. 23) assert(Zp(i) * Zp(i).inv == Zp(1));
	Zp.makeFactorials(22);
	foreach(i; 0 .. 23) assert(Zp.fact[i] * Zp.invFact[i] == Zp(1));
	assert(Zp.C(3, 2) == Zp(3));
	assert(Zp.C(4, 2) == Zp(6));
}
// }}}
