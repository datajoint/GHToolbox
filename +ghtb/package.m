function package(toolboxName, toolboxAuthor, toolboxContact, toolboxSummary, ...
                 toolboxDescription, toolboxExclusions, toolboxVersionHandle, ...
                 toolboxRootFiles, varargin)
    % PACKAGE(toolboxName, toolboxAuthor, toolboxContact, toolboxSummary, ...
    %         toolboxDescription, toolboxExclusions, toolboxVersionHandle, ...
    %         toolboxRootFiles, varargin)
    %   Description:
    %     Provides a programatic way to 'package' MATLAB Community Toolboxes.
    %   Inputs:
    %     toolboxName[required]: (string) Toolbox name, will create as '{{toolboxName}}.mltbx'.
    %     toolboxAuthor[required]: (string) Toolbox author full name.
    %     toolboxContact[required]: (string) Toolbox author email.
    %     toolboxSummary[required]: (string) Toolbox summary. Limit to 140 characters.
    %     toolboxDescription[required]: (string) Toolbox long description.
    %     toolboxExclusions[required]: (cell) Filepaths to exclude. Based from
    %                                  'toolboxRootDir'.
    %     toolboxVersionHandle[required]: (handle) Function that will return semantic version
    %                                              i.e. '0.0.0'
    %     toolboxRootFiles[required]: (cell) Filepaths to include. Based from current
    %                                 directory.
    %     toolboxRootDir[optional, default=pwd]: (string) Local path of Toolbox base directory.
    %     toolboxProjectDir[optional, default=pwd]: (string) Path where Toolbox/.prj will write
    %     toolboxVersionDir[optional, default=pwd]: (string) Path necessary for version func
    %     *toolboxRequiredAddons[optional, default={}]: (cell) Toolboxes or addons to include.
    %     *toolboxScreenshotFile[optional, default='']: (string) Path to icon/screenshot file.
    %     * = Experimental
    %   Examples:
    %     ghtb.package('GHToolbox', ...
    %                  'Raphael Guzman', ...
    %                  'raphael.h.guzman@gmail.com', ...
    %                  ['''ghtb'' provides a simple way to manage addon installation of ' ...
    %                   'open-source MATLAB Community Toolboxes linked to GitHub (via ' ...
    %                   'Releases).'], ...
    %                  'long description', ...
    %                  {'.vscode', '.git', '.env', '.gitignore', '.travis.yml', 'tests', ...
    %                   '*docker-compose.yml', 'LICENSE', 'matlab.prf', 'package.m', ...
    %                   'README.md'}, ...
    %                  @() ghtb.version, ...
    %                  {'+ghtb'});
    %     ghtb.package('mym', ...
    %                  'Raphael Guzman', ...
    %                  'raphael.h.guzman@gmail.com', ...
    %                  'MySQL API for MATLAB with support for BLOB objects', ...
    %                  'long description', ...
    %                  {'mexa64/libmysqlclient.so.18.4.'}, ...
    %                  @() strjoin(arrayfun(@(x) num2str(x), ...
    %                                       cell2mat(struct2cell(mym('version'))), ...
    %                                       'uni', false), ...
    %                              '.'), ...
    %                  {'distribution/mexa64', 'distribution/mexmaci64', ...
    %                   'distribution/mexw64'}, ...
    %                  'toolboxVersionDir', 'distribution/mexa64', ...
    %                  'toolboxRootDir', 'distribution');
    clear('functions'); %needed for uninstall of mex-based toolboxes
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
    addOptional(p, 'toolboxRequiredAddons', {});
    addOptional(p, 'toolboxScreenshotFile', '');
    parse(p, toolboxName, toolboxAuthor, toolboxContact, toolboxSummary, ...
          toolboxDescription, toolboxExclusions, toolboxVersionHandle, ...
          toolboxRootFiles, varargin{:});
    toolboxName = p.Results.toolboxName;
    toolboxAuthor = p.Results.toolboxAuthor;
    toolboxContact = p.Results.toolboxContact;
    toolboxSummary = p.Results.toolboxSummary;
    toolboxDescription = p.Results.toolboxDescription;
    toolboxExclusions = cellfun(@(x) strrep(x, '\', '/'), p.Results.toolboxExclusions, ...
                                'uni', false);
    toolboxVersionHandle = p.Results.toolboxVersionHandle;
    toolboxRootFiles = cellfun(@(x) strrep(x, '\', '/'), p.Results.toolboxRootFiles, ...
                                'uni', false);
    toolboxRootDir = strrep(p.Results.toolboxRootDir, '\', '/');
    toolboxProjectDir = strrep(p.Results.toolboxProjectDir, '\', '/');
    toolboxVersionDir = strrep(p.Results.toolboxVersionDir, '\', '/');
    toolboxRequiredAddons = p.Results.toolboxRequiredAddons;
    toolboxScreenshotFile = strrep(p.Results.toolboxScreenshotFile, '\', '/');
    % get version
    oldpath = pwd;
    cd(toolboxVersionDir);
    toolboxVersion = toolboxVersionHandle();
    cd(oldpath);
    % copy template
    [ghtbRoot, ~, ~] = fileparts(which('ghtb.version'));
    copyfile([ghtbRoot '/package_prj.template'], [toolboxProjectDir '/package.prj']);
    % substitute in values
    fid = fopen([toolboxProjectDir '/package.prj'], 'r');
    f = fread(fid, '*char')';
    fclose(fid);
    f = regexprep(f,'{{NAME}}', toolboxName);
    f = regexprep(f,'{{AUTHOR}}', toolboxAuthor);
    f = regexprep(f,'{{CONTACT}}', toolboxContact);
    f = regexprep(f,'{{SUMMARY}}', toolboxSummary);
    f = regexprep(f,'{{DESCRIPTION}}', strrep(strrep(toolboxDescription, '<', '&lt;'), ...
                                              '&', '&amp;'));
    f = regexprep(f,'{{VERSION}}', toolboxVersion);
    f = regexprep(f,'{{UUID}}', char(java.util.UUID.randomUUID));
    f = regexprep(f,'{{EXCLUSIONS}}', strjoin(toolboxExclusions, '\n'));
    f = regexprep(f,'{{ROOT_FILES}}', strjoin(cellfun(@(x) ['<file>' x '</file>'], ...
                                                      toolboxRootFiles, 'uni', false), '\n'));
    f = regexprep(f,'{{ROOT_DIR}}', toolboxRootDir);
    f = regexprep(f,'{{REQUIRED_ADDONS}}', strjoin(toolboxRequiredAddons, '\n'));
    if ~isempty(toolboxScreenshotFile)
		toolboxScreenshotFile = which(toolboxScreenshotFile);
    end
    f = regexprep(f,'{{SCREENSHOT_FILE}}', toolboxScreenshotFile);
    fid = fopen([toolboxProjectDir '/package.prj'], 'w');
    fprintf(fid,'%s',f);
    fclose(fid);
    % build ToolBox
    matlab.addons.toolbox.packageToolbox([toolboxProjectDir '/package.prj'], ...
                                         [toolboxProjectDir '/' toolboxName]);
    delete([toolboxProjectDir '/package.prj']);
end