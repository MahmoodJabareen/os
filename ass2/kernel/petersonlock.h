struct petersonlock {
    int flag[2] ;
    int turn    ; // whose turn it is
    int used    ; // check if 0 before creating 
    int pid[2]  ;
} ;