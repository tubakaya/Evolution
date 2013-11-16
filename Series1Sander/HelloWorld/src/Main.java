
public class Main {

	public static void main(String[] args) {
		String msg;
		
		msg = getMessage1();
		display(msg);

		msg = getMessage2();
		display(msg);
		
		Extra extra = new Extra();
		display(extra.getText1(1));
		display(extra.getText2(2));
	}
	
	private static void display(String msg) {
		System.out.println(msg);
	}
	
	private static String getMessage1() {
		switch (getNum()) {
		case 0:
			return "Hello 0";
		case 1:
			return "Hello 1";
		default:
			return "Hello something else";
		}
	}

	private static String getMessage2() {
		int i = getNum();
		
		if (i == 1)
			return "Hallo 1";
		else if (i == 2)
			return "Hallo 2";
		else
			return "Hello something else";
	}

	private static int getNum() {
		return 2;
	}
}
