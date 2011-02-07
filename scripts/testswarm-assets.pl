#!/usr/bin/perl

# git hook parameters
my $sha = $ARGV[0];

my $shortsha = $sha;
$shortsha =~ s/^(.{7}).*/$1/;

# The location of the TestSwarm that you're going to run against.
my $SWARM = "http://testswarm1.qa.ec2.gilt.com";

# Your TestSwarm username.
my $USER = "giltassets";

# Your authorization token.
my $AUTH_TOKEN = "b83959a2a10266e11a75ccf6ca05111503539fa1";

# The maximum number of times you want the tests to be run.
my $MAX_RUNS = 5;

# Your git repo
my $REPO = "/home/git/assets";

# The name of the job that will be submitted
# (pick a descriptive, but short, name to make it easy to search)
# Note: The string {REV} will be replaced with the current
#       commit number/hash.
my $JOB_NAME = "Assets Commit <a href=\"http://gblscms.gilt.com:8888/$sha\">#$shortsha</a>";

# The browsers you wish to run against. Options include:
#  - "all" all available browsers.
#  - "popular" the most popular browser (99%+ of all browsers in use)
#  - "current" the current release of all the major browsers
#  - "gbs" the browsers currently supported in Yahoo's Graded Browser Support
#  - "beta" upcoming alpha/beta of popular browsers
#  - "mobile" the current releases of mobile browsers
#  - "popularbeta" the most popular browser and their upcoming releases
#  - "popularbetamobile" the most popular browser and their upcoming releases and mobile browsers
my $BROWSERS = "popularbeta";

my $SUITE = "http://gblscms.gilt.com:8888/$sha/spec/swarm/index.html?specs/";

# What specs to run
my %SUITES = map { /spec\/swarm\/specs\/([\w\/]+).js/; $1 => "$SUITE$1" }
  split(/\n/, `git --git-dir=$REPO ls-tree -r --name-only $sha spec/swarm/specs`);

$JOB_NAME =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;

my %props = (
  "state" => "addjob",
  "output" => "dump",
  "user" => $USER,
  "max" => $MAX_RUNS,
  "job_name" => $JOB_NAME,
  "browsers" => $BROWSERS,
  "auth" => $AUTH_TOKEN
);

my $query = "";

foreach my $prop ( keys %props ) {
  $query .= ($query ? "&" : "") . $prop . "=" . $props{$prop};
}

foreach my $suite ( sort keys %SUITES ) {
  my $url = $SUITES{$suite};
  $url =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;
  $query .= "&suites[]=" . $suite .
            "&urls[]=" . $url;
}

#print "curl --silent -d '$query' $SWARM\n";
`curl --silent -d "$query" $SWARM`;