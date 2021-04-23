LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

ENTITY deterator IS
	PORT (
		  a,b        :IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		  Qout,Rmdr  :OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END deterator;

ARCHITECTURE maxpll OF deterator IS
BEGIN
PROCESS(a,b)
	VARIABLE Avar,Bvar,Tmp,Tmp1: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
Avar := a;
Bvar := b;
a_loop: FOR i IN 7 DOWNTO 0 LOOP
	Tmp:=STD_LOGIC_VECTOR(CONV_UNSIGNED(UNSIGNED(Avar(7 DOWNTO i)),8));  --ʹ�����ͱ�����λ�����,��ͬ����
	IF(Tmp >= Bvar)THEN    --�����������ڳ���ʱ����λ��1
		Qout(i)<='1';
		Tmp1 := Tmp-Bvar;  -- ��ʱ����Ϊ������-����
		IF(i/=0)THEN
			Avar(7 DOWNTO i) := Tmp1(7-i DOWNTO 0);
			Avar(i-1) := a(i-1);
		END IF;

	ELSE                   --������Ϊ��0
		Qout(i)<='0';
		Tmp1 := Tmp;       -- ��ʱ��Ϊ����������
	END IF;         
END LOOP a_loop;
Rmdr <= Tmp1; 
END process;
END maxpll;
