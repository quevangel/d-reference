immutable multi = true;

void solve(int tc)
{
}

// main {{{
void main()
{
	auto t = multi? readInt!int : 1; 
	foreach(tc; 0 .. t) solve(tc);
}
// }}}
// input {{{
int currChar;
static this()
{
	currChar = ' ';
}

char topChar()
{
	return cast(char) currChar;
}

void popChar()
{
	import core.stdc.stdio;
	currChar = getchar();
}

auto readInt(T)()
{
	T num = 0;
	int sgn = 0;
	while (topChar.isWhite)
		popChar;
	while (topChar == '-' || topChar == '+')
	{
		sgn ^= (topChar == '-');
		popChar;
	}
	while (topChar.isDigit)
	{
		num *= 10;
		num += (topChar - '0');
		popChar;
	}
	if (sgn)
		return -num;
	return num;
}

string readString()
{
	string res = "";
	while (topChar.isWhite)
		popChar;
	while (!topChar.isWhite)
	{
		res ~= topChar;
		popChar;
	}
	return res;
}
void writes(T...)(T t)
{
	static foreach(i, ti; t)
	{
		static if (isIterable!(T[i]))
		{
			foreach(e; ti)
			{
				write(e, " ");
			}
		}
	}
}
auto ra(V)()
{
	int n = readInt!int;
	return ma(n, readInt!V);
}
auto rt(V)()
{
	int n = readInt!int;
	int m = readInt!int;
	return ma(n, ma(m, readInt!V));
}
auto rbg()
{
	int n = readInt!int;
	int m = readInt!int;
	auto adj = new int[][](n);
	foreach(i; 0 .. m)
	{
		auto u = readInt!int - 1;
		auto v = readInt!int - 1;
		adj[u] ~= v;
		adj[v] ~= u;
	}
	return adj;
}
auto ma(V)(size_t n, lazy V v)
{
	auto arr = new V[](n);
	foreach(ref ai; arr) ai = v;
	return arr;
}
// }}}
// imports {{{
import std.stdio;
import std.algorithm;
import std.typecons;
import std.math;
import std.numeric;
import std.container;
import std.range;
import std.array;
import std.ascii;
// }}}
