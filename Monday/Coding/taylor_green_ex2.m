%% periodic flow my version
clear all;
clc;

% Macroscopic density and velocities
NX=64;
NY=64;
NPOP=9;
NSTEPS=100*(NX/16)^2;

rho0=1;
umax=0.001;

rho=ones(NX,NY);
ux=zeros(NX,NY);
uy=zeros(NX,NY);

uxinit=zeros(NX,NY);
uyinit=zeros(NX,NY);

feq=zeros(NPOP);
f1=zeros(NPOP,NX,NY);
f2=zeros(NPOP,NX,NY);

weights=[4/9 1/9 1/9 1/9 1/9 1/36 1/36 1/36 1/36];
cx=[0 1 0 -1 0 1 -1 -1 1];
cy=[0 0 1 0 -1 1 1 -1 -1];
omega=1.0;

for y=1:NY
    for x=1:NX
        rho(x,y)=rho0+3*0.25*umax^2*...
            (cos(4*pi*(x-1)/NX)-cos(4*pi*(y-1)/NY));
        ux(x,y)=umax*sin(2*pi*(x-1)/NX)*sin(2*pi*(y-1)/NY);
        uy(x,y)=umax*cos(2*pi*(x-1)/NX)*cos(2*pi*(y-1)/NY);
        vx=ux(x,y);
        vy=uy(x,y);
        
        for k=1:NPOP
            feq(k)=weights(k)*rho(x,y)*(1+3*(vx*cx(k)+vy*cy(k)) ...
               + 9/2*((cx(k)*cx(k)-1/3)*vx*vx+2*cx(k)*cy(k)*vx*vy+(cy(k)*cy(k)-1/3)*vy*vy));
            f1(k,x,y)=feq(k);
            f2(k,x,y)=feq(k);
        end
        
    end
end

for counter=1:NSTEPS
    for y=1:NY
        for x=1:NX
            dense=0;
            vx=0;
            vy=0;
            for k=1:NPOP
                dense=dense+f1(k,x,y);
                vx=vx+cx(k)*f1(k,x,y);
                vy=vy+cy(k)*f1(k,x,y);
            end
            
            rho(x,y)=dense;
            vx = vx/dense;
            vy = vy/dense;
            ux(x,y)=vx;
            uy(x,y)=vy;
             
            for k=1:NPOP
                feq(k)=weights(k)*rho(x,y)*(1+3*(vx*cx(k)+vy*cy(k)) ...
                   +9/2*((cx(k)*cx(k)-1/3)*vx*vx+2*cx(k)*cy(k)*vx*vy+(cy(k)*cy(k)-1/3)*vy*vy));
                
                newx=1+mod(x-1+cx(k)+NX,NX);
                newy=1+mod(y-1+cy(k)+NY,NY);
         
                f1(k,x,y)=f1(k,x,y)*(1-omega)+feq(k)*omega;
                f2(k,newx,newy)=f1(k,x,y);
            end
           
        end
    end
    
    track(counter)=ux(NX/4+1,NY/4+1);
    decay(counter)=umax*exp(-1/3*(1/omega-0.5)*(counter-1)*2*(2*pi/NX)^2);
    f1=f2;
end

plot(1:NSTEPS,track,'+')
xlim([0 NSTEPS])
hold on
plot(1:NSTEPS,decay,'o')


%% Calculation of L2 error
sum=0
for y=1:NX
    for x=1:NX
        ux_value=umax*sin(2*pi*(x-1)/NX)*sin(2*pi*(y-1)/NY)*exp(-1/3*(1/omega-0.5)*(NSTEPS-1)*2*(2*pi/NX)^2);
        uy_value=umax*cos(2*pi*(x-1)/NX)*cos(2*pi*(y-1)/NY)*exp(-1/3*(1/omega-0.5)*(NSTEPS-1)*2*(2*pi/NX)^2);

        sum=sum+(ux(x,y)-ux_value)^2+(uy(x,y)-uy_value)^2;
    end
end
error=sqrt(sum/(NX*NY))

%% Log-log plot (uncomment it when is needed)

%grid=[16,32,64]
%curve=[1e-7,1e-7/4,1e-7/16]
%figure(2)
%loglog(grid,err,grid,curve)
