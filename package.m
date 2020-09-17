function package(toolboxName, toolboxAuthor, toolboxContact, toolboxSummary, ...
                 toolboxDescription, toolboxExclusions, toolboxVersionHandle, varargin)
    % parse input
    p = inputParser;
    addRequired(p, 'toolboxName');
    addRequired(p, 'toolboxAuthor');
    addRequired(p, 'toolboxContact');
    addRequired(p, 'toolboxSummary');
    addRequired(p, 'toolboxDescription');
    addRequired(p, 'toolboxExclusions');
    addRequired(p, 'toolboxVersionHandle');
    addOptional(p, 'rootPackageName', '');
    addOptional(p, 'workingDir', pwd);
    parse(p, toolboxName, toolboxAuthor, toolboxContact, toolboxSummary, ...
          toolboxDescription, toolboxExclusions, toolboxVersionHandle, varargin{:});
    toolboxName = p.Results.toolboxName;
    toolboxAuthor = p.Results.toolboxAuthor;
    toolboxContact = p.Results.toolboxContact;
    toolboxSummary = p.Results.toolboxSummary;
    toolboxDescription = p.Results.toolboxDescription;
    toolboxExclusions = p.Results.toolboxExclusions;
    toolboxVersionHandle = p.Results.toolboxVersionHandle;
    rootPackageName = p.Results.rootPackageName;
    workingDir = p.Results.workingDir;
    % get version
    oldpath = addpath(workingDir);
    toolboxVersion = toolboxVersionHandle();
    path(oldpath);
    % set version
    copyfile([workingDir '/package_template.prj'], [workingDir '/package.prj']);
    fid = fopen([workingDir '/package.prj'], 'r');
    f = fread(fid, '*char')';
    fclose(fid);
    f = regexprep(f,'{{NAME}}', toolboxName);
    f = regexprep(f,'{{AUTHOR}}', toolboxAuthor);
    f = regexprep(f,'{{CONTACT}}', toolboxContact);
    f = regexprep(f,'{{SUMMARY}}', toolboxSummary);
    f = regexprep(f,'{{DESCRIPTION}}', toolboxDescription);
    f = regexprep(f,'{{VERSION}}', toolboxVersion);
    f = regexprep(f,'{{UUID}}', char(java.util.UUID.randomUUID));
    f = regexprep(f,'{{EXCLUSIONS}}', toolboxExclusions);
    if isempty(rootPackageName)
        f = regexprep(f,'{{ROOT_FILES}}', ['\${PROJECT_ROOT}/' toolboxName '.m']);
    else
        f = regexprep(f,'{{ROOT_FILES}}', ['\${PROJECT_ROOT}/+' rootPackageName]);
    end
    f = regexprep(f,'{{WORKDIR}}', workingDir);
    fid = fopen([workingDir '/package.prj'], 'w');
    fprintf(fid,'%s',f);
    fclose(fid);
    % % build ToolBox
    matlab.addons.toolbox.packageToolbox([workingDir '/package.prj'], ...
                                         [workingDir '/' toolboxName]);
end