function tintColMap=generate_colorMap(value_code)
%Function generates the number of colours that are used to draw the
%ratemaps

%tintColMap=zeros(10, 3);
if value_code == 1
    tintColMap=[1 1 1; 0 0 0.6; 0 0 0.8; 0 0.5 1; 0.2 0.7 0.9;...
    0.3 0.9 0.6;  0.4 1 0.3; 0.9 1 0.1; 1 0.8889 0; 1 0.7778 0; 1 0 0];
elseif value_code == 2

    tintColMap=[0.1 0.1 0.9; 0 0 0.6; 0 0 0.8; 0 0.5 1; 0.2 0.7 0.9;...
    0.3 0.9 0.6;  0.4 1 0.3; 0.9 1 0.1; 1 0.8889 0; 1 0.7778 0; 1 0 0];

end

%colormap(tintColMap); colorbar;
end