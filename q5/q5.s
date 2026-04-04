.section .data
filename:
    .asciz "input.txt"
yes:
    .asciz "Yes\n"
no:
    .asciz "No\n"

.section .bss
buf: .space 2              # 2-byte buffer

.section .text
.global main

main:
    addi sp,sp,-16
    sd ra,8(sp)

    #### open input.txt ####

    li a0,-100             # AT_FDCWD
    la a1,filename         # pointer to "input.txt"
    li a2,0                # O_RDONLY
    li a3,0                # mode (unused)
    li a7,56               # syscall: openat
    ecall

    mv s0,a0               # save file descriptor in s0

    #### get file size ####

    mv a0,s0               # fd
    li a1,0                # offset = 0
    li a2,2                # SEEK_END
    li a7,62               # syscall: lseek
    ecall

    mv s1,a0               # s1 = file size

    #### if empty file or single byte , print yes ####
    blez s1,end
    li t0,1
    ble s1,t0,end

    #### check last byte for newline ####

    addi t1,s1,-1         # last position
    mv a0,s0
    mv a1,t1   
    li a2,0               # SEEK_SET
    li a7,62
    ecall

    mv a0,s0 
    la a1,buf
    li a2,1               # read 1 byte
    li a7,63
    ecall
    lb t2,0(a1)

    li t3,10              # newline '\n'
    bne t2,t3,skip_newline
    addi s1,s1,-1         # remove newline from size

skip_newline:
    li s2,0               # left = 0
    addi s3,s1,-1         # right = size - 1

    j loop

loop:
    bge s2,s3,end         # if left >= right, end

    #### get left char ####

    mv a0,s0              # fd 
    mv a1,s2              # offset = left
    li a2,0               # SEEK_SET
    li a7,62              # syscall: lseek
    ecall

    mv a0,s0 
    la a1,buf             # static buffer
    li a2,1               # read 1 byte
    li a7,63              # syscall: read
    ecall

    lb t0,0(a1)           # t0 = str[left]

    #### get right char ####

    mv a0,s0              # fd
    mv a1,s3              # offset = right
    li a2,0               # SEEK_SET
    li a7,62              # syscall: lseek
    ecall

    mv a0,s0 
    la a1,buf             # static buffer
    li a2,1               # read 1 byte
    li a7,63              # syscall: read
    ecall

    lb t1,0(a1)           # t1 = str[right]

    bne t0,t1,not_pal_end # if str[left] != str[right], end 

    addi s2,s2,1          # left++
    addi s3,s3,-1         # right--

    j loop

end:
    li a0,1               # fd = stdout
    la a1,yes             # pointer to "Yes\n"
    li a2,4               # length
    li a7,64              # write syscall
    ecall

    li a0,0               # exit code 0
    li a7,93              # exit syscall
    ecall

not_pal_end:
    li a0,1               # fd = stdout
    la a1,no              # pointer to "No\n"
    li a2,3               # length
    li a7,64              # write syscall
    ecall

    li a0,0              # exit code 0
    li a7,93             # exit syscall
    ecall



