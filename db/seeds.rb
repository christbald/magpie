# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'open3'

#### Generate the reviewer accounts
#File.open('/tmp/reviewerpasses.txt', 'w') { |file|
#file.write("User\tPassword\n")
#for i in 1..20
#  mail = "rev#{i}@magpie.nar.review"
#  pw = Faker::Internet.password(8)
#  file.write("#{mail}\t#{pw}\n")
#  @u1 = User.create!( name:                   "ReviewerAccount#{i}",
#                      identity:               "revacc#{i}",
#                      email:                  mail,
#                      password:               pw,
#                      password_confirmation:  pw,
#                      admin:                  false,
#                      activated:              true,
#                      activated_at:           Time.zone.now)
#  @u1.create_right
#  @u1.right.user_delete = false
#  @u1.right.update_attribute("model_add", true)
#end
#}

require 'mini_magick'


@u1 = User.create!( name:                   "Admin",
                    identity:               "admin",
                    email:                  "admin@admin.com",
                    password:               "admin_password_17",
                    password_confirmation:  "admin_password_17",
                    admin:                  true,
                    activated:              true,
                    activated_at:           Time.zone.now)
@u1.create_right

@u1 = User.create!( name:             "Non-Admin User",
              identity:               "nonadminu",
              email:                  "user@user.kp",
              password:               "nonadmin.mypass?.7699_8",
              password_confirmation:  "nonadmin.mypass?.7699_8",
              activated:              true,
              activated_at:           Time.zone.now)
@u1.create_right

@b1 = User.create!( name:                   Rails.application.config.postbot_name,
              identity:               "postbot",
              email:                  Rails.application.config.postbot_email,
              password:               "nonadmin.mypass?.7699_9",
              password_confirmation:  "nonadmin.mypass?.7699_9",
              bot:                    true,
              activated:              true,
              activated_at:           Time.zone.now)
@b1.create_right

@b2 = User.create!( name:                   Rails.application.config.tutorialbot_name,
              identity:               "tutorialbot",
              email:                  Rails.application.config.tutorialbot_email,
              password:               "nonadmin.mypass?.7699_9",
              password_confirmation:  "nonadmin.mypass?.7699_9",
              bot:                    true,
              activated:              true,
              activated_at:           Time.zone.now)
@b2.create_right

@model1 = Model.create!(name:        "Versioned Sleep Studies",
              description:           "Sleeps for a given amount of time.
                                     Time [s] can be set as an argument.",
              help:                  "",
              source:                File.open("#{Rails.application.config.root}/test/zip/sleep.zip"),
              category:              'Showcase',
              user_id:               User.find_by(name: "Admin").id)
@model1.initializer
[{tag: "versions"}, {tag: "sleepy"}, {tag: "myfirstmodel"}].each do |tagdata|
  @model1.hashtags.create(tagdata) end
@model1.save
# Now, let's create some more random revisions in the repository
tmp_path = Dir.mktmpdir
system("cd #{tmp_path}; git clone #{@model1.path} #{tmp_path}")
p "Using #{tmp_path} as working directory for sleep."
for i in 0..10
  randomtag = Faker::App.version
  randomtagdesc = Faker::Hacker.say_something_smart.gsub("'", "")
  randomcommitmessage = Faker::Lorem.sentence
  fakefile = Faker::Name.name
  p randomtag, randomtagdesc, randomcommitmessage, fakefile
  system("cd #{tmp_path}; touch '#{fakefile}'; git add -A; git tag -a v#{randomtag} -m '#{randomtagdesc}';")
  system("cd #{tmp_path}; git commit -m '#{randomcommitmessage}'; git push origin master --tags;")
  revision, status = Open3.capture2("cd #{@model1.path}; git rev-parse --verify HEAD;")
  p revision, randomtag
  @model1.mainscript[revision.strip] = "sleep.sh"
  @model1.save
end

@model2 = Model.create!(name:        "Fail!",
              description:           "Runs a job with a syntax error in the bash script. Will fail 100%.",
              help:                  "",
              source:                File.open("#{Rails.application.config.root}/test/zip/failed.zip"),
              user_id:               User.find_by(name: "Admin").id,
              category:              "Showcase")
@model2.initializer
[{tag: "completefailure"}, {tag: "owned"}, {tag: "syntaxerror"}].each do |tagdata|
  @model2.hashtags.create(tagdata) end
@model2.save

#@model3 = Model.create!(name:        "PFSPA",
#              description:           "Novel particle system combining reaction-diffusion with motion.",
#              help:                  "",
#              source:                File.open("#{Rails.application.config.root}/test/zip/pfspa.zip"),
#              category:              'Cell Modelling',
#              user_id:               User.find_by(name: "Christoph Baldow").id)
#@model3.initializer
#[{tag: "PFSPA"}, {tag: "particles"}].each do |tagdata|
#  @model3.hashtags.create(tagdata) end
#@model3.save

multiplexingclonality_desc = File.open(File.join(Rails.root, 'test', 'seedextra', 'multiplexing_clonality_description.md')).read
@model4 = Model.create!(name:        "Multiplexing Clonality",
              description:           multiplexingclonality_desc,
              help:                  "",
              source:                File.open("#{Rails.application.config.root}/test/zip/multiplex.zip"),
              user_id:               User.find_by(name: "Admin").id,
              doi:                   "10.1093/nar/gku081",
              citation:              "Cornils, Kerstin et al. “Multiplexing Clonality: Combining RGB Marking and Genetic Barcoding.” Nucleic Acids Research 42.7 (2014): e56. PMC. Web. 13 Dec. 2016.",
              category:              "Sequencing",
              logo:                  MiniMagick::Image.open("#{Rails.application.config.root}/test/zip/logos/multiplexing_clonality.png").to_blob)
@model4.initializer
[{tag: "attackoftheclones"}, {tag: "barcoding"}, {tag: "fancy"}].each do |tagdata|
  @model4.hashtags.create(tagdata) end
@model4.save

@model5 = Model.create!(name:         "D3 Plot Visualization",
                        description:  "Model for creating and testing all different d3 plots, including barcharts, boxplots, histograms and stacked plots.",
                        help:         "Find more information about interactive plots in MAGPIE here: https://magpie.imb.medizin.tu-dresden.de/help?section=Interactive%20Plots",
                        source:        File.open("#{Rails.application.config.root}/test/zip/d3Model.zip"),
                        category:     'Showcase',
                        user_id:      User.find_by(name: "Admin").id)
@model5.initializer
@model5.save


plip_desc = File.open(File.join(Rails.root, 'test', 'seedextra', 'plip_description.md')).read
plip_help = File.open(File.join(Rails.root, 'test', 'seedextra', 'plip_help.md')).read
@model6 = Model.create!(name:         "PLIP",
                        description:  plip_desc,
                        help:         plip_help,
                        source:       File.open("#{Rails.application.config.root}/test/zip/pliplocal.zip"),
                        user_id:      User.find_by(name: "Admin").id,
                        doi:          "10.1093/nar/gkv315",
                        citation:     "Salentin,S. et al. PLIP: fully automated protein-ligand interaction profiler. Nucl. Acids Res. (1 July 2015) 43 (W1): W443-W447.",
                        category:     'Structural Bioinformatics',
                        logo:         MiniMagick::Image.open("#{Rails.application.config.root}/test/zip/logos/plip.png").to_blob)
@model6.initializer
@model6.save

@model7 = Model.create!(name:         "Configuration & Parameter Example",
                        description:  "This model is used to show the usage of all possible input parameter types.",
                        help:         "Find more information about configuration files in MAGPIE here: https://magpie.imb.medizin.tu-dresden.de/help?section=Configuration%20Files",
                        source:        File.open("#{Rails.application.config.root}/test/zip/ConfigurationExample.zip"),
                        user_id:      User.find_by(name: "Admin").id,
                        doi:          "",
                        citation:     "",
                        category:     "Showcase")
@model7.initializer
@model7.save

clonal_leukemia_desc = File.open(File.join(Rails.root, 'test', 'seedextra', 'clonal_leukemia_description.md')).read
clonal_leukemia_help = File.open(File.join(Rails.root, 'test', 'seedextra', 'clonal_leukemia_help.md')).read
@model8 = Model.create!(name:         "Clonal Leukemia",
                        description: clonal_leukemia_desc,
                        help:         clonal_leukemia_help,
                        source:       File.open("#{Rails.application.config.root}/test/zip/clonalleukemia.zip"),
                        user_id:      User.find_by(name: "Admin").id,
                        doi:          "10.1371/journal.pone.0165129",
                        citation:     "Baldow C, Thielecke L, Glauche I (2016) Model Based Analysis of Clonal Developments Allows for Early Detection of Monoclonal Conversion and Leukemia. PLoS ONE 11(10): e0165129.",
                        category:     "Medical Science",
                        logo:         MiniMagick::Image.open("#{Rails.application.config.root}/test/zip/logos/clonalleukemia.png").to_blob)
@model8.initializer
@model8.save

sbml_showcase_STAT1_desc = File.open(File.join(Rails.root, 'test', 'seedextra', 'sbml_showcase_STAT1_description.md')).read
sbml_showcase_STAT1_help = File.open(File.join(Rails.root, 'test', 'seedextra', 'sbml_showcase_STAT1_help.md')).read
@model9 = Model.create!(name:         "SBML: STAT1 activity in pancreatic cancer",
                        description:  sbml_showcase_STAT1_desc,
                        help:         sbml_showcase_STAT1_help,
                        source:       File.open("#{Rails.application.config.root}/test/zip/STAT1ActivityPancreaticCancer.zip"),
                        user_id:      User.find_by(name: "Admin").id,
                        doi:          "10.1371/journal.pcbi.1002815",
                        citation:     "Rateitschak K1, Winter F, Lange F, Jaster R, Wolkenhauer O. (2012) Parameter identifiability and sensitivity analysis predict targets for enhancement of STAT1 activity in pancreatic cancer and stellate cells. PLoS Comput Biol. 2012;8(12):e1002815.",
                        category:     "Showcase",
                        logo:         MiniMagick::Image.open("#{Rails.application.config.root}/test/zip/logos/sbml.png").to_blob)
@model9.initializer
@model9.save


################# Tutorial Projects and jobs ####################

# Sleep (Get Started Tutorial)
@project1 = Project.create!(name:       "Tutorial Sleep",
                            user_id:    @b2.id, # TutorialBot
                            model_id:   @model1.id,
                            public:     true,
                            revision:   @model1.current_revision)
@project1.assign_unique_hashtag

@p1_job = Job.create!(status:     "finished",
                      user_id:    @b2.id,
                      project_id: @project1.id,
                      output: {:stdout=>['Slept for 5 seconds!'], :stderr=>[]},
                      resultfiles: [],
                      directory: File.join(Rails.root, 'test', 'tutorialjobs', 'sleeptut').to_s,
                      arguments: nil,
                      highlight: "neutral",
                      docker_id: "08b19d69e7c6")

@project12 = Project.create!(name:       "Tutorial Sleep 2",
                            user_id:    @b2.id, # TutorialBot
                            model_id:   @model1.id,
                            public:     true,
                            revision:   @model1.current_revision)
@p12_job = Job.create!(status:     "finished",
                      user_id:    @b2.id,
                      project_id: @project12.id,
                      output: {:stdout=>['Slept for 5 seconds!'], :stderr=>[]},
                      resultfiles: [],
                      directory: File.join(Rails.root, 'test', 'tutorialjobs', 'sleeptut').to_s,
                      arguments: nil,
                      highlight: "neutral",
                      docker_id: "08b19d69e7c6")


# PLIP (Advanced Tutorial)
@project2 = Project.create!(name:       "Tutorial PLIP",
                            user_id:    @b2.id, # TutorialBot
                            model_id:   @model6.id,
                            public:     true,
                            revision:   @model6.current_revision)
@project2.assign_unique_hashtag

@p2jdir = File.join(Rails.root, 'test', 'tutorialjobs', 'pliptut')
@p2jresults = [File.join(@p2jdir, 'report.txt'), File.join(@p2jdir, '1VSN_NFT_A_283.png'), File.join(@p2jdir, '1VSN_NFT_A_283.pse'), File.join(@p2jdir, 'report.xml'), File.join(@p2jdir, '1vsn.pdb'), File.join(@p2jdir, 'distances.data')]
@p2_job = Job.create!(status:     "finished",
                      user_id:    @b2.id,
                      project_id: @project2.id,
                      output: {:stdout=>[], :stderr=>[]},
                      resultfiles: @p2jresults,
                      directory: @p2jdir.to_s,
                      arguments: nil,
                      highlight: "neutral",
                      docker_id: "08b19d69e7c6")



#############

if !Pathname.new("#{Rails.application.config.root}/test/zip/magpie-default.docker.zip").exist?
  system("cd #{Rails.application.config.root}/test/zip; wget https://magpie.imb.medizin.tu-dresden.de/magpie-default.docker.zip")
end

# Initialize the docker image
# TODO: integrate in execution: docker run -it -v /Users/baldow/.magpie/docker/:/root -w /root magpie:default ./run_mf.sh
system("rm -fR #{Rails.application.config.docker_path}")
system("mkdir #{Rails.application.config.docker_path}")
Zip::File.open("#{Rails.application.config.root}/test/zip/magpie-default.docker.zip") do |zip_file|
  zip_file.each do |f|
    fpath = File.join("#{Rails.application.config.docker_path}", File.basename(f.name))
    zip_file.extract(f, fpath) unless File.exist?(fpath)
  end
end
Docker::Image.load("#{Rails.application.config.docker_path}/magpie-default.docker")
