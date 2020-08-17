let project = new Project('New Project');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');
project.addLibrary('differ')
project.addLibrary('poly2trihx')
resolve(project);
