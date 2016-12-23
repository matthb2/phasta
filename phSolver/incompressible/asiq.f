        subroutine AsIq (blk, y,       x,       shp,
     &                   shgl,    ien,     xmudmi,
     &                   qres,    rmass    )
c
c----------------------------------------------------------------------
c
c This routine computes and assembles the data corresponding to the
c interior elements for the global reconstruction of the diffusive
c flux vector.
c
c input:
c     y     (numnp,ndof)        : Y variables
c     x     (numnp,nsd)         : nodal coordinates
c     shp   (nen,nintg)         : element shape-functions
c     shgl  (nsd,nen,nintg)     : element local shape-function gradients
c     ien   (blk%e)              : nodal connectivity array
c
c output:
c     qres  (numnp,nsd,nsd)  : residual vector for diffusive flux
c     rmass  (numnp)            : lumped mass matrix
c
c----------------------------------------------------------------------
c
        use turbsa      ! access to d2wall
      use eblock
        include "common.h"
      type (LocalBlkData) blk

c
        dimension y(nshg,ndof),               x(numnp,nsd),            
     &            shp(blk%s,blk%g),         shgl(nsd,blk%s,blk%g),
     &            ien(blk%e,blk%s),      dwl(bsz,blk%n),
     &            qres(nshg,idflx),    rmass(nshg)
c
        dimension yl(bsz,blk%s,ndof),          xl(bsz,blk%n,nsd),
     &            ql(bsz,blk%s,idflx),  rmassl(bsz,blk%s),
     &            xmudmi(blk%e,blk%g)
c
        dimension sgn(blk%e,blk%s)
c
c.... create the matrix of mode signs for the hierarchic basis 
c     functions. 
c
        do i=1,blk%s
           where ( ien(:,i) < 0 )
              sgn(:,i) = -one
           elsewhere
              sgn(:,i) = one
           endwhere
        enddo

c
c.... gather the variables
c

        call localy(blk,y,      yl,     ien,    ndof,   'gather  ')
        call localx (blk,x,      xl,     ien,    nsd,    'gather  ')
        if (iRANS .eq. -2) then ! kay-epsilon
           call localx (d2wall,   dwl,     ien,    1,     'gather  ')
        endif
c
c.... get the element residuals 
c
        ql     = zero
        rmassl = zero

        call e3q  (blk,yl,         dwl,      shp,      shgl,    
     &             xl,         ql,       rmassl,
     &             xmudmi,     sgn  )

c
c.... assemble the diffusive flux residual 
c
        call local (blk,qres,   ql,  ien,  idflx,  'scatter ')
        call local (blk,rmass,  rmassl, ien,  1,          'scatter ')
c
c.... end
c
        return
        end


c
c----------------------------------------------------------------------
c
c This routine computes and assembles the data corresponding to the
c interior elements for the global reconstruction of the diffusive
c flux vector.
c
c----------------------------------------------------------------------
       subroutine AsIqSclr (blk,y,       x,       shp,
     &                       shgl,    ien,     qres,    
     &                       rmass    )
c
        use turbsa      ! access to d2wall
      use eblock
        include "common.h"
      type (LocalBlkData) blk

c
        dimension y(nshg,ndof),             x(numnp,nsd),            
     &            shp(blk%s,blk%g),         shgl(nsd,blk%s,blk%g),
     &            ien(blk%e,blk%s),      dwl(bsz,blk%n),
     &            qres(nshg,nsd),           rmass(nshg)
c
        dimension yl(bsz,blk%s,ndof),       xl(bsz,blk%n,nsd),         
     &            ql(bsz,blk%s,nsd),        rmassl(bsz,blk%s)
c
        dimension sgn(blk%e,blk%s)

        if (blk%o .gt. 1) then
           call getsgn(blk,ien,sgn)
        endif
c
c.... gather the variables
c
        call localy(blk,y,      yl,     ien,    ndof,   'gather  ')
        call localx (blk,x,      xl,     ien,    nsd,    'gather  ')
        if (iRANS .eq. -2) then ! kay-epsilon
           call localx (blk,d2wall,   dwl,     ien,    1,     'gather  ')
        endif
c
c.... get the element residuals 
c
        ql     = zero
        rmassl = zero

        call e3qSclr  (blk,yl,      dwl,    shp,    shgl,    
     &                 xl,      ql,     rmassl, 
     &                 sgn             )

c
c.... assemble the temperature diffusive flux residual 
c
        call local (blk,qres,   ql,  ien,  nsd,  'scatter ')
        call local (blk,rmass,  rmassl, ien,  1, 'scatter ')
c
c.... end
c
        return
        end

