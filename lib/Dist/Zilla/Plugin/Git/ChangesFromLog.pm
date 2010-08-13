package Dist::Zilla::Plugin::Git::ChangesFromLog;
# ABSTRACT: Build your changelog from your git log

use Moose;


=attr max_age

Changelog entries will be created from commit log entries no older
than this many days. The default value is C<365>

B<RFC:> What about the idea of allowing anything that can be parsed
by something like L<Time::ParseDate>? For example, anything that
isn't an integer is parsed and the resulting timestamp becomes the
cut-off date for oldest log entry.

=cut

has max_age => (
    is      => 'ro',
    isa     => 'Int',
    default => 365,
);



=attr tag_regexp

You should tag your released versions using a scheme that is easily
identifiable by a regex, which is what you specify here. The default
value is C<^v\d+_\d+$>

The current best practice seems to be to tag releases using the
version number prefixed by a 'C<v>'. (eg. C<v0.123>, C<v20100810>,
C<v2.12_003>, etc...)

=cut

has tag_regexp => (
    is      => 'ro',
    isa     => 'Str',
    default => '^v\\d+_\\d+$',
);



=attr file_name

The name of your Changelog file. If this file does not exist it
will be created. If it I<does> exist, new changelog entries will
be added according to your other settings.

=cut

has file_name => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Changes',
);



=attr write_policy

How to write to the changelog - C<update> or C<overwrite>.

=for :list
= update
(default) add new entries to the file, according to the
L<write_order>
= overwrite
generate a new changelog file, overwriting any existing one.

=cut

has write_policy => (
    is      => 'ro',
    isa     => 'Str',
    default => 'update',
);



=attr write_order

This specifies the order in which changelog entries will be written
to the changelog file.

=for :list
= prepend
(default) add new entries to the I<top> of the file, so that the
newest entries are at the I<beginning>.
= append
add the newest entries to the I<bottom> of the file, so that the
newest entries are at the I<end>.

=cut

has write_order => (
    is      => 'ro',
    isa     => 'Str',
    default => 'prepend',
);



=attr filter_class

Each I<log entry> from your vcs will is expected ultimately become
a I<line> in your changelog - or not. This option will allow you to
create your own filtering functionality for these entries by
rejecting, accepting, and munging them as you please!

The given class will be instantiated once, and each I<log entry>
will be passed to that object's C<filter> method.

If the I<log entry> is to be I<rejected> (and therefore not used in
the changelog), C<undef> must be returned.

If the I<log entry> is to be I<accepted>, it should be returned and
that returned value will be used in the resulting changelog entry.

If you so desire, you can split a I<log entry> into multiple pieces
and return them as a list - each returned value will become a new
line to add to the changelog. For the purpose of ordering, the
I<first> value returned be considered the I<newest>.

The default value is equal to C<__PACKAGE__>, so it's whatever class
this plugin is defined in.

The behavior of the default filter is to accept every string,
completely unmodified.

B<RFC>: Is this a totally hare-brained idea? Am I going about it all
wrong? I I<know> I'm not sure about the default values and behaviors!
Let me know what you think!

=cut

has filter_class => (
    is      => 'ro',
    isa     => 'Str',
    default => __PACKAGE__,
);




'pancakes are good'; # truth

=pod

=head1 OVERVIEW

I'd like some input on this, so here goes:

I want to think about changelogs in an abstract, structured way.
I recognize that they can be relatively free-form, but there are
nearly *always* some common elements and some structure to them!

For example, changelogs may have lines with the following info:

  - who applied each change (committer?)
  - who made each changes (patch author)
  - who made each release (releaser?)
  - the date of each release
  - the date of each change
  - the version of each release
  - the description of each change

So, I see several "objects" standing out:

  - Project
    - @releases
    - %other_info (url, repo, author, lang, license, etc?)

  - Release
    - $author (releaser? maintainer?)
    - $date
    - $version
    - $name? (name of package? release code-name?)
    - $arbitrary_text?
    - @associated_changes
    - %other_info (thanks to, url, etc?)

  - Change
    - $associated_release
    - $author
    - $commiter (applier?)
    - $date
    - $date_applied?
    - $description (may contain newlines? or be an array of lines?)
    - %other_info (commit hash, bug #, etc, etc)

  - Person
    - $name
    - $email
    - $public_key
    - etc...

This plugin will be designed to *not* clobber existing entries, and in
the interest of usability, I think it should scan existing changelog
entries for parsable dates, and only insert new entries that are *newer*
than the most recent date found.

B<HOW HARD COULD IT BE!!?!> C<;-)>

=head1 WHY

So.. I<Why> did I make yet another Changelog-From-Git module?

Simple - because I don't like the format of the changelogs generated
by the dzil plugins currently available for this task, and neither
do the auth and release tests I use. Also, I want to provide a whole
lot more flexibility than the others.

=head1 PLANS

This dzil plugin should be designed to allow for:

=for :list
* template-driven generation of changelog entries
* sanely B<updating> existing changelogs
* third-party extensions
* optionally re-writing changelogs
* optionally B<everything>

=cut
