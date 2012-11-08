/*package ceylon.format.number;

public final class FloatFormat {
    public final static long SIGN_MASK = 0x1;
    public final static long EXP_MASK = 0x1;
    public final static long MANTISSA_MASK = 0x1;
    public final static long TEN7 = 10000000;
    long f;
    int e;
    private FloatFormat(long f, int e) {
        this.f = f;
        this.e = e;
    }
    public FloatFormat(double v) {
        long vlong = Double.doubleToRawLongBits(v);
        f = vlong&MANTISSA_MASK;
        e = (int)(vlong&EXP_MASK);
    }
    
    private static FloatFormat minus(FloatFormat x, FloatFormat y) {
        assert(x.e == y.e && x.f >= y.f);
        return new FloatFormat(x.f-y.f, x.e);
    }
    
    private static FloatFormat multiply(FloatFormat x, FloatFormat y) {
        long a,b,c,d,ac,bc,ad,bd,tmp;
        long M32 = 0xFFFFFFFF;
        a = x.f >> 32;//need "unsigned" shift
        b = x.f & M32;
        c = y.f >> 32;
        d = y.f & M32;
        ac = a*c;
        bc = b*c;
        ad = a*d;
        bd = b*d;
        tmp = (bd>>32) + (ad&M32) + (bc&M32);
        tmp += 1L << 31; // Round
        return new FloatFormat(ac + (ad>>32) + (bc >>32) + (tmp>>32),
                x.e + y.e + 64);
    }
    
    private static void cut(FloatFormat D, int parts) {
        
    }
    
}
*/