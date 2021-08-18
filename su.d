// Sets Unions Structure {{{
struct SU
{
	int[] p;
	int[] s;
	this(int n)
	{
		p = new int[](n);
		s = new int[](n);
		foreach(i, ref pi; p)
		{
			pi = i;
			s[i] = 1;
		}
	}
	void unite(int v, int w)
	{
		v = rep(v); 
		w = rep(w);
		if (s[v] > s[w]) swap(v, w);
		p[v] = w;
		s[w] += s[v];
	}
	int rep(int v)
	{
		return parent[v] == v? v : parent[v] = rep(parent[v]);
	}
}
//}}}
