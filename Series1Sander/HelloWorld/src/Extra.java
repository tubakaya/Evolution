
public class Extra {
	public String getText1(int i) {
		switch (i) {
		case 0:
			return "Hello 0";
		case 1:
			return "Hello 1";
		default:
			return "Hello something else";
		}
	}

	public String getText2(int i) {
		if (i == 1)
			return "Hallo 1";
		else if (i == 2)
			return "Hallo 2";
		else
			return "Hello something else";
	}
}
