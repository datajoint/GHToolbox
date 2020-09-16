function package(toolboxName, toolboxAuthor, toolboxContact, toolboxSummary, ...
                 toolboxDescription, toolboxExclusions, rootPackageName, varargin)
    % parse input
    p = inputParser;
    addRequired(p, 'toolboxName');
    addRequired(p, 'toolboxAuthor');
    addRequired(p, 'toolboxContact');
    addRequired(p, 'toolboxSummary');
    addRequired(p, 'toolboxDescription');
    addRequired(p, 'toolboxExclusions');
    addRequired(p, 'rootPackageName');
    addOptional(p, 'workingDir', '.');
    parse(p, toolboxName, toolboxAuthor, toolboxContact, toolboxSummary, ...
          toolboxDescription, toolboxExclusions, rootPackageName, varargin{:});
    toolboxName = p.Results.toolboxName;
    toolboxAuthor = p.Results.toolboxAuthor;
    toolboxContact = p.Results.toolboxContact;
    toolboxSummary = p.Results.toolboxSummary;
    toolboxDescription = p.Results.toolboxDescription;
    toolboxExclusions = p.Results.toolboxExclusions;
    rootPackageName = p.Results.rootPackageName;
    workingDir = p.Results.workingDir;
    % get version
    oldpath = addpath(workingDir);
    toolboxVersion = eval([rootPackageName '.version']);
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
    f = regexprep(f,'{{ROOT_FILES}}', ['\${PROJECT_ROOT}/+' rootPackageName]);
    fid = fopen([workingDir '/package.prj'], 'w');
    fprintf(fid,'%s',f);
    fclose(fid);
    % % build ToolBox
    matlab.addons.toolbox.packageToolbox([workingDir '/package.prj'], ...
                                         [workingDir '/' toolboxName]);
end