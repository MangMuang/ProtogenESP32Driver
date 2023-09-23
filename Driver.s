.section .text
.globl _start

.equ UART_BASE, 0x3FF40000
.equ UART_CLKDIV, 0x00A0
.equ UART_WDATA, 0x00A4
.equ UART_RDATA, 0x00AC
.equ UART_STATUS, 0x00A8

.equ I2S_BASE, 0x3FF00000
.equ I2S_CONF, 0x0000
.equ I2S_SAMPLE_RATE, 0x0004
.equ I2S_DATA_OUT, 0x0024

.equ UART_CLKDIV_VAL, 80

.equ GPIO_BASE, 0x3FF44000
.equ GPIO_OUTPUT_EN, 0x004
.equ GPIO_OUTPUT_VAL, 0x008

.equ LED_PIN, 2

.equ SPI_BASE, 0x3FFYYYYY
.equ SPI_CMD_REG, 0xZZZ
.equ SPI_DATA_REG, 0xWWW

.equ LCD_CS_PIN, 5
.equ LCD_DC_PIN, 4

_start:
    li a0, UART_BASE
    li a1, UART_CLKDIV_VAL
    sw a1, UART_CLKDIV(a0)

    li a0, I2S_BASE
    li a1, 0x3000
    sw a1, I2S_CONF(a0)

    li a0, I2S_BASE
    li a1, 44100
    sw a1, I2S_SAMPLE_RATE(a0)

    li a0, GPIO_BASE
    li a1, (1 << LED_PIN)
    sw a1, GPIO_OUTPUT_EN(a0)
	
	li a0, SPI_BASE
    li a1, 0x00
    sw a1, SPI_CMD_REG(a0)
	
	li a0, GPIO_BASE
    li a1, (1 << LCD_CS_PIN) | (1 << LCD_DC_PIN)
    sw a1, GPIO_OUTPUT_EN(a0)

    li a0, GPIO_BASE
    li a1, (1 << LCD_CS_PIN)
    sw a1, GPIO_OUTPUT_VAL(a0)

    call lcd_init

loop:
	call lcd_send_command
    li a1, 0x36
    call lcd_send_data
    li a1, 0x48

    li a0, UART_BASE
    lw a1, UART_STATUS(a0)
    andi a1, a1, 0x01
    beqz a1, loop

    li a0, UART_BASE
    lw a1, UART_RDATA(a0)

    li a2, 'M'
    beq a1, a2, check_next

    j loop

check_next:
    li a0, UART_BASE
    lw a1, UART_RDATA(a0)

    li a2, 'M'
    bne a1, a2, loop


blink_led:
    li a0, GPIO_BASE
    li a1, (1 << LED_PIN)
    sw a1, GPIO_OUTPUT_VAL(a0)

    li a1, 500000
delay:
    subi a1, a1, 1
    bnez a1, delay

    li a0, GPIO_BASE
    sw zero, GPIO_OUTPUT_VAL(a0)

pass_through:
    li a0, I2S_BASE
    lw a1, I2S_CONF(a0)
    andi a1, a1, 0x100
    beqz a1, pass_through

    li a0, I2S_BASE
    sw a2, I2S_DATA_OUT(a0)

    j loop

lcd_init:
    #LCD Init


lcd_send_command:
    li a0, GPIO_BASE
    li a1, (1 << LCD_DC_PIN)
    sw a1, GPIO_OUTPUT_VAL(a0)
	;Send CMD

lcd_send_data:
    li a0, GPIO_BASE
    li a1, (1 << LCD_DC_PIN)
    sw a1, GPIO_OUTPUT_VAL(a0)
	;Send DAT
