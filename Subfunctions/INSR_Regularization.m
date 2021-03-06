function  [im1, im_out, im_wei]  =  INSR_Regularization( im, X_m, opts, Dict, lam, flag )
[h, w, ch]   =   size(im);
b          =   opts.win;
b2         =   b*b*ch;
k          =   0;
s          =   opts.step;
PCA_D      =   Dict.PCA_D;
PCA_idx    =   Dict.cls_idx;
s_idx      =   Dict.s_idx;
seg        =   Dict.seg;

N     =  h-b+1;
M     =  w-b+1;
L     =  N*M;
r     =  1:s:N;
r     =  [r r(end)+1:N];
c     =  1:s:M;
c     =  [c c(end)+1:M];
X     =  zeros(b*b,L,'single');
for i  = 1:b
    for j  = 1:b
        k    =  k+1;
        blk  =  im(i:h-b+i,j:w-b+j);
        blk  =  blk(:);
        X(k,:) =  blk';            
    end
end

ind        =   zeros(N,M);
ind(r,c)   =   1;
X          =   X(:, ind~=0);
X          =   X - X_m;

N          =   length(r);
M          =   length(c);
L          =   N*M;
Y          =   zeros( b2, L );

for   i  = 1:length(seg)-1   
    idx    =   s_idx(seg(i)+1:seg(i+1));    
    cls    =   PCA_idx(idx(1));
    P      =   reshape(PCA_D(:, cls), b2, b2);
    t1     =   opts.t1;
    if  flag==1 
        t1    =   lam(:, idx);
    end
    Y(:, idx)      =   P'*( soft(P*X(:,idx), t1) ) + X_m(:,idx);
end

im_out   =  zeros(h,w);
im_wei   =  zeros(h,w);
k        =  0;
for i  = 1:b
    for j  = 1:b
        k    =  k+1;
        im_out(r-1+i,c-1+j)  =  im_out(r-1+i,c-1+j) + reshape( Y(k,:)', [N M]);
        im_wei(r-1+i,c-1+j)  =  im_wei(r-1+i,c-1+j) + 1;       
    end
end
im1    =  im_out./(im_wei+eps);
return;