// binary search: firstThat, lastThat {{{
auto firstThat(alias f, I)(I lo, I hi)
{
	I ans = hi + 1;
	while (lo <= hi)
	{
		I mid = (lo + hi)/2;
		if (f(mid))
		{
			ans = mid;
			hi = mid - 1;
		}
		else
		{
			lo = mid + 1;
		}
	}
	return ans;
}
auto lastThat(alias f, I)(I lo, I hi)
{
	I ans = lo - 1;
	while (lo <= hi)
	{
		I mid = (lo + hi)/2;
		if (f(mid))
		{
			ans = mid;
			lo = mid + 1;
		}
		else
		{
			hi = mid - 1;
		}
	}
	return ans;
}

unittest
{
	assert(firstThat!(n => n * n >= 25)(0, 25) == 5);
	auto arr = [0, 1, 2, 3, 4, 5];
	assert(firstThat!(n => arr[n] >= 4)(0, arr.length - 1) == 4);
	assert(lastThat!(n => n * n < 10000)(0, 10000) == 99);
}
// }}}
