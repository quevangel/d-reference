// STL V, U, f, fou, uou, fName, uName {{{
struct STL(V, U, 
		V neutral,
		alias f, 
		alias fou, 
		alias uou, 
		string fName = "f", string uName = "u")
{
	struct Node
	{
		V f;
		U u;
		bool hasU;
	}
	Node[] _n;
	size_t length = 0;
	int layers = 0;
	this(size_t n, V v)
	{
		bool isPow2(size_t s) { return ((s - 1) & s) == 0; }
		import std.math;
		import core.bitop;
		layers = bsr(n) + !isPow2(n);
		n = 1 << (layers++);
		length = n;
		auto noNodes = 2 * n; 

		_n = new Node[](noNodes);

		foreach(i; n .. 2 * n) 
		{ 
			_n[i].f = v; 
		}
		foreach_reverse(i; 1 .. n) 
		{ 
			_n[i].f = f(_n[i<<1].f, _n[(i<<1)^1].f); 
		}
	}
	void _clearU(size_t l, size_t r)
	{
		pragma(inline, true);
		foreach_reverse(layer; 1 .. layers)
		{
			auto lowerBits = (1 << layer) - 1;
			if (l & lowerBits) _clearU(l >> layer);
			if (r & lowerBits) _clearU(r >> layer);
		}
	}
	void _refresh(size_t l, size_t r)
	{
		pragma(inline, true);
		foreach(layer; 1 .. layers)
		{
			auto lowerBits = (1 << layer) - 1;
			if (l & lowerBits) _refresh(l >> layer);
			if (r & lowerBits) _refresh(r >> layer);
		}
	}
	void _refresh(size_t i)
	{
		pragma(inline, true);
		assert(!_isLeaf(i));
		_n[i].f = f(_n[i<<1].f, _n[(i<<1)^1].f);
	}
	V rangeF(size_t l, size_t r)
	{
		l += length, r += length;
		_clearU(l, r);
		V value = neutral;
		for(; l < r; l >>= 1, r >>= 1)
		{
			if (l & 1) 
				value = f(value, _n[l++].f); 
			if (r & 1) 
				value = f(value, _n[--r].f); 
		}
		return value;
	}
	mixin(q{alias }, fName, q{Range = rangeF;});
	void rangeU(size_t l, size_t r, U u)
	{
		l += length, r += length;
		auto ol = l, or = r;
		_clearU(l, r);
		for(; l < r; l >>= 1, r >>= 1)
		{
			if (l & 1) _addU(l++, u); 
			if (r & 1) _addU(--r, u);
		}
		_refresh(ol, or);
	}
	static if (uName == "set")
	{
		auto opIndexAssign(U u, size_t[2] slice)
		{
			rangeU(slice[0], slice[1], u);
			return this;
		}
	}
	else static if (uName == "add")
	{

	}
	bool _isLeaf(size_t i)
	{
		pragma(inline, true);
		return i >= length;
	}
	void _clearU(size_t i)
	{
		pragma(inline, true);
		if (!_n[i].hasU) return;
		assert(!_isLeaf(i));
		_n[i].hasU = false;
		_addU(i << 1, _n[i].u), _addU((i << 1) ^ 1, _n[i].u);
		assert(_n[i].f == f(_n[i<<1].f, _n[(i<<1)^1].f));
	}
	void _addU(size_t i, U u)
	{
		import core.bitop;
		pragma(inline, true);
		if (!_n[i].hasU)
		{
			_n[i].hasU = true;
			_n[i].u = u;
		}
		else
		{
			_n[i].u = uou(u, _n[i].u);
		}
		_n[i].f = fou(_n[i].f, u, length >> bsr(i));
	}
	size_t[2] opSlice(size_t i)(size_t start, size_t end) if (i == 0)
	{
		return [start, end];
	}
}
template TSTL(V, string f, string u, neutral...)
{
	alias funF = mixin(f);
	alias funUoU = mixin(u);
	alias funFoU = mixin(f, "O", u);
	static if (neutral.length == 1)
		immutable neut = neutral[0];
	else static if (neutral.length == 0)
	{
		alias neutralTemplate = mixin(f, "Neutral");
		immutable neut = neutralTemplate!V;
	}
	else static assert(false);
	alias TSTL = STL!(V, V, neut, funF!V, funFoU!V, funUoU!V, f, u);
}
immutable maxNeutral(T) = T.min;
pure T max(T)(T a, T b)
{
	pragma(inline, true);
	return a > b? a : b;
}
immutable addNeutral(T) = T(0);
pure T add(T)(T a, T b)
{
	pragma(inline, true);
	return a + b;
}
pure T min(T)(T a, T b)
{
	pragma(inline, true);
	return a < b? a : b;
}
pure T set(T)(T a, T b)
{
	pragma(inline, true);
	return a;
}
pure T maxOset(T)(T mx, T set, size_t l)
{
	pragma(inline, true);
	return set;
}
pure T maxOadd(T)(T mx, T ad, size_t l)
{
	pragma(inline, true);
	return mx + ad;
}
pure T minOset(T)(T mx, T set, size_t l)
{
	pragma(inline, true);
	return set;
}
pure T minOadd(T)(T mx, T ad, size_t l)
{
	pragma(inline, true);
	return mx + ad;
}
pure T addOadd(T)(T sm, T ad, size_t l)
{
	pragma(inline, true);
	return sm + ad * cast(T)l;
}

long nextPow2(long n)
{
	int p = 1;
	for(; p < n; p <<= 1) {}
	return p;
}

unittest
{
	import std.algorithm;
	import std.random;
	import std.stdio;
	alias SumQSumU = TSTL!(int, "add", "add");
	version(velocity)
	{
		int n = 100_000;
		int q = 100_000;
		auto st = SumQSumU(n, 0);
		int tot = 0;
		foreach(i; 0 .. q)
		{
			int f = uniform!"[)"(0, n);
			int t = uniform!"[]"(f + 1, n);
			if (i&1)
			{
				tot += st.addRange(f, t);
			}
			else
			{
				int u = uniform!"[)"(-1000, 1000);
				st.rangeU(f, t, u);
			}
		}
	}
	else
	{
		auto n = 1000;
		int[] brute = new int[](n);
		auto smart = SumQSumU(n, 0);
		int rounds = 10;
		foreach(round; 0 .. rounds)
		{
			foreach(i; 0 .. n)
				foreach(j; i + 1 .. n + 1)
				{
					int v = uniform!"[]"(1, 20);
					brute[i .. j] += v;
					smart.rangeU(i, j, v);
				}
			foreach(i; 0 .. n)
				foreach(j; i + 1 .. n + 1)
				{
					auto bruteAnswer = brute[i .. j].fold!((a, b) => (a + b));
					auto smartAnswer = smart.rangeF(i, j);
					assert(bruteAnswer == smartAnswer);
				}
		}
	}
}
// }}}
