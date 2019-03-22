HOST=$1
NAME=$2
PORT=$3
PASSWORD=$4

set -e

module load wcEcoli/sherlock2
pyenv local wcEcoli2

make clean
make compile

PYTHONPATH=$PWD:$PYTHONPATH nosetests -a 'smalltest' --with-xunit --with-coverage --cover-package=wholecell --cover-xml

sh runscripts/jenkins/fireworks-config.sh $HOST $NAME $PORT $PASSWORD

echo y | lpad reset

PYTHONPATH=$PWD DESC="2 generations completion test." WC_ANALYZE_FAST=1 SINGLE_DAUGHTERS=1 N_GENS=2 MASS_DISTRIBUTION=0 PARALLEL_FITTER=1 COMPRESS_OUTPUT=0 python runscripts/fireworks/fw_queue.py

PYTHONPATH=$PWD rlaunch rapidfire --nlaunches 0

N_FAILS=$(lpad get_fws -s FIZZLED -d count)

test $N_FAILS = 0

# TODO (John): These calls are disabled because the files weren't appearing
# quickly enough, post-analysis.  Consequently the PR test build was failing
# despite running all of the code without issue.  If and when these issues are
# addressed, the lines can be restored.  See #316

# export TOP_DIR="$PWD"

# cd out/2*/wildtype_000000/000000/generation_000000/000000/plotOut/low_res_plots/

# curl -F file=@massFractionSummary.png -F channels=#jenkins -F token=xoxb-17787270916-3VkwrS6348nn9DJz8bDs6EYG https://slack.com/api/files.upload

# cd $TOP_DIR
# cd out/2*/wildtype_000000/000000/plotOut/low_res_plots/

# curl -F file=@massFractionSummary.png -F channels=#jenkins -F token=xoxb-17787270916-3VkwrS6348nn9DJz8bDs6EYG https://slack.com/api/files.upload

# cd $TOP_DIR
# cd out/2*/wildtype_000000/plotOut/low_res_plots/

# curl -F file=@massFractionSummary.png -F channels=#jenkins -F token=xoxb-17787270916-3VkwrS6348nn9DJz8bDs6EYG https://slack.com/api/files.upload
# cd $TOP_DIR
# rm -fr out/*