.section .data
filename:   
    .asciz "input.txt"
mode_r:
    .asciz "r"
yes:
    .asciz "Yes\n"
no: 
    .asciz "No\n"

.section .text
.global main

main:
    addi sp,sp,-32
    sd ra,24(sp)
    sd s0,16(sp)
    sd s1,8(sp)
    sd s2,0(sp)

    #### fopen("input.txt", "r") ####
    la a0,filename
    la a1,mode_r
    call fopen
    mv s0,a0                # s0 = file pointer

    #### fseek(fp, 0, SEEK_END) to get size ####
    mv a0,s0
    li a1,0
    li a2,2                 # SEEK_END
    call fseek

    #### ftell(fp) ####
    mv a0,s0
    call ftell
    mv s1,a0                # s1 = file size

    #### if single char or empty string, print yes ####
    blez s1,print_yes
    li t0,1
    ble s1,t0,print_yes

    #### check last byte for newline ####
    mv a0,s0
    addi a1,s1,-1           # seek to last byte
    li a2,0                 # SEEK_SET
    call fseek

    mv a0,s0
    call fgetc              # read last char
    li t1,10                # '\n'
    bne a0,t1,skip_newline
    addi s1,s1,-1           # strip newline from size

skip_newline:
    li s2,0                 # left = 0
    addi s3,s1,-1           # right = size - 1
    sd s3,0(sp)             # save s3 

    j loop

loop:
    ld s3,0(sp)             # restore s3
    bge s2,s3,print_yes

    #### fseek to left ####
    mv a0,s0
    mv a1,s2
    li a2,0                 # SEEK_SET
    call fseek

    mv a0,s0
    call fgetc
    mv s4,a0                # s4 = str[left]  

    #### fseek to right ####
    ld s3,0(sp)
    mv a0,s0
    mv a1,s3
    li a2,0                 # SEEK_SET
    call fseek

    mv a0,s0
    call fgetc              # a0 = str[right]

    bne s4,a0,print_no

    addi s2,s2,1            # left++
    ld s3,0(sp)
    addi s3,s3,-1           # right--
    sd s3,0(sp)

    j loop

print_yes:
    la a0,yes
    call printf
    j end

print_no:
    la a0,no
    call printf

end:
    li a0,0
    ld ra,24(sp)
    ld s0,16(sp)
    ld s1,8(sp)
    ld s2,0(sp)
    addi sp,sp,32
    ret
    