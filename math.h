/** Returns base to the exp'th power.
  Complexity: o(log(exp))
  From https://stackoverflow.com/questions/101439/
*/
int ipow(int base, int exp)
{
    int result = 1;
    for (;;)
    {
        if (exp & 1)
            result *= base;
        exp >>= 1;
        if (!exp)
            break;
        base *= base;
    }

    return result;
}
