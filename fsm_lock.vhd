----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/03/27 13:06:59
-- Design Name: 
-- Module Name: fsm_lock - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm_lock is
  Port (
        rst : in std_logic;
        clk : in std_logic;
        clk_1hz : in std_logic;
        sw : in std_logic_vector(3 downto 0);
        btn1, btn2, btn3 : in std_logic;
        d1, d0 : out std_logic_vector(3 downto 0);  -- ����������λ�����
        led_lock, led_emrg : out std_logic  -- ָʾ�����ͱ���
         );
end fsm_lock;

architecture Behavioral of fsm_lock is

constant c4 : unsigned(3 downto 0) := "1001";  -- 9
constant c3 : unsigned(3 downto 0) := "0100";  -- 4
constant c2 : unsigned(3 downto 0) := "0011";  -- 3
constant c1 : unsigned(3 downto 0) := "0110";  -- 6
constant c0 : unsigned(3 downto 0) := "0100";  -- 4
signal c43210 : unsigned(19 downto 0):=c4&c3&c2&c1&c0;
signal c_emrg : unsigned(19 downto 0):=c0&c1&c2&c3&c4;  -- ���尲ȫ�������������ķ���
signal c_random : unsigned(7 downto 0);  -- ���ֵ���
signal c_random1 : unsigned(3 downto 0); -- ������ĵ�һλ��ֵ
signal c_random2 : unsigned(3 downto 0);  -- ����ڶ�λ��ֵ

signal r4, r3, r2, r1, r0 : unsigned(3 downto 0);  -- ���뻺���current state
signal r4_n, r3_n, r2_n, r1_n, r0_n : unsigned(3 downto 0);  -- �������һ��״̬
signal r43210 : unsigned(19 downto 0);  -- ����������뻺�����
signal r10 : unsigned(7 downto 0);  -- �Ľ��������뻺�����

signal half_min, two_min, five_min : std_logic := '0';  -- �ȴ�ʱ���indicator
signal flag : std_logic := '0';  -- Ϊ��1����ʾ�ȴ�����

type state_type is   -- ����״̬������״̬
    (locked, unlocked, emrg, t4, t3, t2, t1, t0, u1, u0, 
        comp1, comp2, wait_30s, wait_2m, wait_5m);

signal state, state_n : state_type;  -- ״̬��current state �� next state

begin

    nx_state:process(clk, rst)  -- ״̬������
    begin
      if (rst = '1') then  -- ��ʼ��
         state <= locked;
         r4 <= (others=>'0');
         r3 <= (others=>'0');
         r2 <= (others=>'0');
         r1 <= (others=>'0');
         r0 <= (others=>'0');
      elsif rising_edge(clk) then  -- �����ظ���
         state <= state_n;
         r4 <= r4_n;
         r3 <= r3_n;
         r2 <= r2_n;
         r1 <= r1_n;
         r0 <= r0_n;
      end if;
    end process;
    
    ramdom:process(clk, btn3)  -- �����������λ
        variable cnt_o : unsigned(2 downto 0):="001";
        variable cnt_e : unsigned(2 downto 0):="010";
    begin
        if rising_edge(clk) then
            if cnt_o >= 5 then  -- ��������������
                cnt_o := "001";
            else
                cnt_o := cnt_o + 2;
            end if;
            if cnt_e = 4 then  -- 2��4����
                cnt_e := "010";
            else
                cnt_e := "100";
            end if;
        end if;
        
        if btn3='1' then  -- ȡ�����°�ťʱ������������ֵ
            case cnt_o is
            when "001" =>
                c_random1 <= c4;
                d1 <= "0001";
            when "011" => 
                c_random1 <= c2;
                d1 <= "0011";
            when "101" => 
                c_random1 <= c0;
                d1 <= "0101";
            when others =>
                c_random1 <= c4;
                d1 <= "0001";
            end case;
            
            case cnt_e is  -- ȡ�����°�ťʱ��ż��ֵ
            when "010" =>
                c_random2 <= c3;
                d0 <= "0010";
            when "100" => 
                c_random2 <= c1;
                d0 <= "0100";
            when others =>
                c_random2 <= c3;
                d0 <= "0010";
            end case;
            
        end if;
    end process;
    c_random <= c_random1 & c_random2;  -- ƴ��������
    
    timer : process(clk_1hz, half_min, two_min, five_min)  -- ��ʱ�������ڵȴ�ʱ��
        variable cnt : integer:=0;
    begin
        if half_min='1' then  -- ����indicatorȷ���ȴ�ʱ��
            if rising_edge(clk_1hz) then
                cnt := cnt + 1 ;
                if cnt=30 then
                    flag <= '1';
                    cnt := 0;
                end if;
            end if;
        elsif two_min='1' then
            if rising_edge(clk_1hz) then
                cnt := cnt + 1 ;
                if cnt=120 then
                    flag <= '1';
                    cnt := 0;
                end if;
            end if;
        elsif five_min='1' then
            if rising_edge(clk_1hz) then
                cnt := cnt + 1 ;
                if cnt=300 then
                    flag <= '1';
                    cnt := 0;
                end if;
            end if;
        else
            cnt := 0;
            flag <= '0';
        end if;
        
    end process;
    
    r43210 <= r4&r3&r2&r1&r0; 
    r10 <= r1&r0; 
    cu_state:process(state, btn1, btn2, btn3,  -- ״̬�������߼�ʵ�ֲ���
                    r4, r3, r2, r1, r0, flag)
        variable try : integer;  -- �����Դ���
    begin
        -- default values
        state_n <= state;
        r4_n <= r4;
        r3_n <= r3;
        r2_n <= r2;
        r1_n <= r1;
        r0_n <= r0;
        
        case state is 
        
        when locked =>   -- ����״̬
            half_min <= '0';  -- �ȴ�����
            two_min <= '0';
            five_min <= '0';
            
            if btn1='1' then  -- ���ݰ�ťѡ���������Ľ���
                state_n <= t4;
            elsif btn3='1' then
                state_n <= u1;
            end if;
            
            led_lock <= '1';  -- ����
            led_emrg <= '0';  -- ����״̬�²�����
            try := 2;  -- ��������

        when unlocked =>   -- ����״̬
            led_lock <= '0';  -- ����
            led_emrg <= '0';  -- ������
--            try := 2;  -- �������裬�������Ӧ��ע��
            
        when emrg =>   -- ����״̬
            led_lock <= '0';  -- ����
            led_emrg <= '1';  -- ����
--            try := 2;
            
        when wait_30s =>   -- ��30��
            half_min <= '1';
            if flag='1' then
                state_n <= locked;
            end if;

        when wait_2m =>   -- ��������
            two_min <= '1';
            if flag='1' then
                state_n <= locked;
                two_min <= '0';
            end if;

        when wait_5m =>   -- 5���� 
            five_min <= '1';
            if flag='1' then
                state_n <= locked;
                five_min <= '0';
            end if;
            
        when t4 =>   -- ��ȡ���λ�����루��һλ
            if rising_edge(btn2) then
                r4_n <= unsigned(sw(3 downto 0));
                state_n <= t3;
            end if;
            
        when t3 =>   -- ���ڶ�λ
            if btn1='1' then
                state_n <= t4;
            elsif rising_edge(btn2) then
                r3_n <= unsigned(sw(3 downto 0));
                state_n <= t2;
            end if;

        when t2 =>   -- ��
            if btn1='1' then
                state_n <= t4;
            elsif rising_edge(btn2) then
                r2_n <= unsigned(sw(3 downto 0));
                state_n <= t1;
            end if;
            
        when t1 =>   -- ��
            if btn1='1' then
                state_n <= t4;
            elsif rising_edge(btn2) then
                r1_n <= unsigned(sw(3 downto 0));
                state_n <= t0;
            end if;
            
        when t0 =>   -- ��
            if btn1='1' then
                state_n <= t4;
            elsif rising_edge(btn2) then
                r0_n <= unsigned(sw(3 downto 0));
                state_n <= comp1;
            end if;
            
        when u1 =>   -- �Ľ�����ȡ��һλ
            if rising_edge(btn2) then
                r1_n <= unsigned(sw(3 downto 0));
                state_n <= u0;
            end if;

        when u0 =>   -- �Ľ�����ȡ�ڶ�λ
            if btn3='1' then
                state_n <= u1;
            elsif rising_edge(btn2) then
                r0_n <= unsigned(sw(3 downto 0));
                state_n <= comp2;
            end if;

        when comp1 =>  -- ������ȶ�
            if rising_edge(btn2) then
                if r43210=c43210 then
                    state_n <= unlocked;
                elsif r43210=c_emrg then
                    state_n <= emrg;
                else 
--                    if try<5 then 
                        try := try+1; 
--                    else 
--                        try := 5;
--                    end if;
                    
                    if try=3 then  -- ���ݴ�����������Ƿ����ȴ��Լ��ȴ�ʱ��
                        state_n <= wait_30s;
                    elsif try=4 then
                        state_n <= wait_2m;
                    elsif try>=5 then
                        state_n <= wait_5m;
                    else
                        state_n <= t4;
                    end if;
                end if;
            end if;
            
        when comp2 =>  -- �Ľ����ȶ�
            if rising_edge(btn2) then
                if r10=c_random then
                    state_n <= unlocked;
                else
--                    if try<5 then 
                        try := try+1; 
--                    else 
--                        try := 5;
--                    end if;
                    
                    if try=3 then  -- ���ݴ�����������Ƿ����ȴ��Լ��ȴ�ʱ��
                        state_n <= wait_30s;
                    elsif try=4 then
                        state_n <= wait_2m;
                    elsif try>=5 then
                        state_n <= wait_5m;
                    else
                        state_n <= u1;
                    end if;    
                end if;
            end if;
            
        end case;
        
    end process;

end Behavioral;
