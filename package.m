function package(toolboxName, toolboxAuthor, toolboxContact, toolboxSummary, ...
                 toolboxDescription, toolboxExclusions, toolboxVersionHandle, ...
                 toolboxRootFiles, varargin)
    % parse input
    p = inputParser;
    addRequired(p, 'toolboxName');
    addRequired(p, 'toolboxAuthor');
    addRequired(p, 'toolboxContact');
    addRequired(p, 'toolboxSummary');
    addRequired(p, 'toolboxDescription');
    addRequired(p, 'toolboxExclusions');
    addRequired(p, 'toolboxVersionHandle');
    addRequired(p, 'toolboxRootFiles');
    addOptional(p, 'toolboxRootDir', pwd);
    addOptional(p, 'toolboxProjectDir', pwd);
    addOptional(p, 'toolboxVersionDir', pwd);
    parse(p, toolboxName, toolboxAuthor, toolboxContact, toolboxSummary, ...
          toolboxDescription, toolboxExclusions, toolboxVersionHandle, ...
          toolboxRootFiles, varargin{:});
    toolboxName = p.Results.toolboxName;
    toolboxAuthor = p.Results.toolboxAuthor;
    toolboxContact = p.Results.toolboxContact;
    toolboxSummary = p.Results.toolboxSummary;
    toolboxDescription = p.Results.toolboxDescription;
    toolboxExclusions = p.Results.toolboxExclusions;
    toolboxVersionHandle = p.Results.toolboxVersionHandle;
    toolboxRootFiles = p.Results.toolboxRootFiles;
    toolboxRootDir = p.Results.toolboxRootDir;
    toolboxProjectDir = p.Results.toolboxProjectDir;
    toolboxVersionDir = p.Results.toolboxVersionDir;
    % get version
    oldpath = addpath(toolboxVersionDir);
    toolboxVersion = toolboxVersionHandle();
    path(oldpath);
    % set version
    copyfile([toolboxProjectDir '/package_template.prj'], [toolboxProjectDir '/package.prj']);
    fid = fopen([toolboxProjectDir '/package.prj'], 'r');
    f = fread(fid, '*char')';
    fclose(fid);
    f = regexprep(f,'{{NAME}}', toolboxName);
    f = regexprep(f,'{{AUTHOR}}', toolboxAuthor);
    f = regexprep(f,'{{CONTACT}}', toolboxContact);
    f = regexprep(f,'{{SUMMARY}}', toolboxSummary);
    f = regexprep(f,'{{DESCRIPTION}}', toolboxDescription);
    f = regexprep(f,'{{VERSION}}', toolboxVersion);
    f = regexprep(f,'{{UUID}}', char(java.util.UUID.randomUUID));
    f = regexprep(f,'{{EXCLUSIONS}}', strjoin(toolboxExclusions, '\n'));
    f = regexprep(f,'{{ROOT_FILES}}', strjoin(cellfun(@(x) ['<file>' x '</file>'], ...
                                                      toolboxRootFiles, 'uni', false), '\n'));
    f = regexprep(f,'{{ROOT_DIR}}', toolboxRootDir);
    fid = fopen([toolboxProjectDir '/package.prj'], 'w');
    fprintf(fid,'%s',f);
    fclose(fid);
    % % build ToolBox
    matlab.addons.toolbox.packageToolbox([toolboxProjectDir '/package.prj'], ...
                                         [toolboxProjectDir '/' toolboxName]);
end