# [Sentosa AutoForms](http://learningmason.wordpress.com/)

Sentosa AutoForms aims to provide a web interface for databases, with forms, subforms, tables and reports, etc.

## Getting Started

August 2015: It's still very early in development. Please come back soon, I have some code but not much to show now. Some basic interface will be ready around half of September 2015.

Install cpanminus:

    yum install cpanminus

Install CPAN modules:

    cpanm --notest Poet
    cpanm DBD::SQLite
    cpanm Log::Log4perl
    cpanm Log::Any::Adapter::Log4perl

Prepare local db:

    bin/install_db.sh

Run Poet in development mode:

    bin/run.pl

Open with your browser:

    http://localhost:5000

You can now login with user: admin, password: password or user: user, password: password

## Creator

[Federico Thiella on Stackoverflow](http://stackoverflow.com/users/833073/fthiella)

## License

I'm using this bootstrap admin template [SB Admin 2](http://startbootstrap.com/template-overviews/sb-admin-2/)

## My blog

I started this project because:

* I'm interested in databases
* I actually need a simple web interface for my databases. Other apps I tried didn't suit my needs.
* I find [Mason](http://www.masonhq.com) a great and powerful Perl-based templating system, and I want to learn how to use it better

I'm documenting the developement process here:
http://learningmason.wordpress.com

:)
