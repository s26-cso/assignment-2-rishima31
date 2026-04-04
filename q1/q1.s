.global make_node
.global insert
.global get
.global getAtMost

make_node:
    addi sp,sp,-16
    sd ra,8(sp)

    mv t0,a0                # t0 = val

    li a0,24
    call malloc             # a0 = pointer to new node

    sw t0,0(a0)             # store val 
    sd x0,8(a0)             # left = NULL
    sd x0,16(a0)            # right = NULL

    ld ra,8(sp)
    addi sp,sp,16
    ret

###########################################

insert:
    addi sp,sp,-32
    sd ra,24(sp)            # save return address
    sd a0,16(sp)            # save root
    sd a1,8(sp)             # save val

    beq a0,x0,call_m_n      # if root == NULL, create new node

    lw t0,0(a0)             # t0 = root->val

    blt a1,t0,go_left       # val < root->val → go left
    bgt a1,t0,go_right      # val > root->val → go right

    ld ra,24(sp)
    addi sp,sp,32
    ret

call_m_n:
    ld a0,8(sp)             # a0 = val
    call make_node          # returns new node in a0

    ld ra,24(sp)
    addi sp,sp,32
    ret

go_left:
    ld a0,8(a0)             # a0 = root->left
    ld a1,8(sp)             # a1 = val
    call insert             # returns updated left subtree

    ld t1,16(sp)            # t1 = root (restored from stack)
    sd a0,8(t1)             # root->left = returned node

    mv a0,t1                # return root
    ld ra,24(sp)
    addi sp,sp,32
    ret

go_right:
    ld a0,16(a0)            # a0 = root->right
    ld a1,8(sp)             # a1 = val
    call insert             # returns updated right subtree

    ld t1,16(sp)            # t1 = root (restored from stack)
    sd a0,16(t1)            # root->right = returned node

    mv a0,t1                # return root
    ld ra,24(sp)
    addi sp,sp,32
    ret

###########################################

get:   
    addi sp,sp,-24
    sd ra,16(sp)            # save return address
    sd a0,8(sp)             # save root
    sd a1,0(sp)             # save val

    beq a0,x0,end_get       # if root == NULL, end

    lw t0,0(a0)             # t0 = root->val

    beq a1,t0,found         # if root->val==val, go to found

    blt a1,t0,find_left     # if val < root->val go left
    bgt a1,t0,find_right    # if val > root->val go right

    ld ra,16(sp)
    addi sp,sp,24
    ret

end_get:
    mv a0,x0                # return NULL (0)
    ld ra,16(sp)            # a0 already has root value so just return that
    addi sp,sp,24
    ret


found:
    ld ra,16(sp)            # a0 already has root value so just return that
    addi sp,sp,24
    ret

find_left:
    ld a0,8(a0)             # a0 = root->left
    ld a1,0(sp)             # a1 = val

    call get

    ld ra,16(sp)
    addi sp,sp,24
    ret

find_right:
    ld a0,16(a0)            # a0 = root->right
    ld a1,0(sp)             # a1 = val

    call get

    ld ra,16(sp)
    addi sp,sp,24
    ret

###########################################

getAtMost:
    addi sp,sp,-32
    sd ra,24(sp)            # save return address
    sd a0,16(sp)            # save val
    sd x0,0(sp)             # initialize predecessor = NULL

    beq a1,x0,end           # if root==NULL, end

    sd a1,8(sp)             # save a1 = root (current node)

loop:
    ld t0,8(sp)             # load curr
    beq t0,x0,check_end     # if curr==NULL, go to check_end

    ld a0,16(sp)            # a0 = val
    lw t1,0(t0)             # t1 = curr->val

    beq a0,t1,pred          # if val==root->val go to pred

    bgt a0,t1,right         # if val > root->val go right
    j left                  # val < root->val go left

right:
    ld t0,8(sp)             # load curr
    sd t0,0(sp)             # save curr as predecessor

    ld t1,16(t0)            # t1 = curr->right
    sd t1,8(sp)             # update curr to curr->right

    j loop                  # run loop again

left:
    ld t0,8(sp)             # load curr

    ld t1,8(t0)             # t1 = curr->left
    sd t1,8(sp)             # update curr to curr->left

    j loop                  # run loop again

pred:
    ld t0,8(sp)
    lw a0,0(t0)             # return curr->val directly
    ld ra,24(sp)
    addi sp,sp,32
    ret

check_end:
    ld t0,0(sp)             # t0 = predecessor
    beq t0,x0,end           # if NULL, no valid answer

    lw a0,0(t0)             # return predecessor->val
    ld ra,24(sp)
    addi sp,sp,32
    ret

end:
    li a0,-1
    ld ra,24(sp)
    addi sp,sp,32
    ret