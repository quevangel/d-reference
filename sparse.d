// sparse table V, f, fName {{{
struct Sparse(V, alias f, string fName = "value")
{
	import std.math : log2;
	V[][] _table;
	int[] maxPow;
	this(V[] values)
	{
		auto n = values.length;
		maxPow = new int[](n + 1);
		maxPow[0] = int.min;
		maxPow[1] = 0;
		foreach(i; 2 .. n + 1)
		{
			int prev = maxPow[i - 1];
			maxPow[i] = prev;
			prev = (1 << prev);
			if (prev * 2 <= i) maxPow[i]++;
		}
		_table = new V[][](maxPow[n] + 1, n);
		_table[0][] = values[];

		foreach(p; 1 .. maxPow[n] + 1)
		foreach(i; 0 .. n - (1<<p) + 1)
			_table[p][i] = f(_table[p-1][i], _table[p-1][i+(1<<(p-1))]);
	}
	int[2] opSlice(size_t i)(size_t start, size_t end) if (i == 0)
	{
		return [cast(int)start, cast(int)end];
	}
	auto opIndex(int[2] slice)
	{
		int sliceLen = slice[1] - slice[0];
		auto x = maxPow[sliceLen];
		auto twoX = (1 << x);
		auto p1 = _table[x][slice[0]];
		auto p2 = _table[x][slice[1] - twoX];
		struct Ans
		{
			mixin(q{V }, fName, q{;});
		}
		return Ans(f(p1, p2));
	}
}

unittest
{
	import std.algorithm;
	import std.stdio;
	alias MinQ = Sparse!(int, min, "min");
	writeln("testing");
	int[] array = [1, 2, 3, 4, -2, -2, -3, 0, 10];
	auto minQ = MinQ(array); 
	foreach(i; 0 .. array.length)
	{
		foreach(j; i + 1 .. array.length + 1)
		{
			assert(minQ[i .. j].min == array[i .. j].fold!min);
		}
	}
}
// }}}
