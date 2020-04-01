function X = loadshape(input1)
    % loadshape - load an input shape and compute the features and eigenpairs
    % input1: either a mesh (as a struct) OR a file containing a mesh

    %% load mesh
    
    if isstruct(input1)
        X = input1;
    else
        fileName = char(input1);
    
        [~,~,extension] = fileparts(fileName);
        
        switch extension
            case '.off'
                [X.vert,X.triv] = read_off(fileName);
                X.vert = X.vert';
                X.triv = X.triv';
            case '.obj'
                [X.vert,X.triv] = read_obj(fileName);
            case '.ply'
                [X.vert,X.triv] = read_ply(fileName);
            case '.mat'
                load(fileName,'X');
        end
    
    end
    
    
    X.n = size(X.vert,1);
    X.m = size(X.triv,1);
    
    %shift to Middle
    X.vert = X.vert-mean(X.vert,1);
    
    %rescale
    refarea = 0.44; 
    X.vert = X.vert ./ sqrt(sum(calc_tri_areas(X))) .* sqrt(refarea);     
    
    %% compute features
    
    kMax = 500;
    
    X.samples = (1:X.n)';

    X.neigh = struct;
    X.neigh.mat = getNeighborsTRIV(X.triv,X.n);
    [X.neigh.row,X.neigh.col] = find(X.neigh.mat(X.samples,:));


    X.vertSub = X.vert(X.samples,:);
    X.area = sum(calc_tri_areas(X));
    X = computeLBeigenpairs(X,kMax);

    XSmooth = smoothshapesigmoid(X,kMax);

    [X.normal,~,X.flipNormal] = compute_normal(XSmooth.vert',XSmooth.triv');
    X.normal = X.normal';

end

