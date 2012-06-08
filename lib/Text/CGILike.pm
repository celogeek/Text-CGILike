package Text::CGILike;

# ABSTRACT: Wrapper to create text file using the CGI syntax

use strict;
use warnings;
use Moo;
use Text::Format;

# VERSION

our (@ISA, @EXPORT, %EXPORT_TAGS);

BEGIN {
    require Exporter;

    my @html2 = qw/start_html end_html hr h1 ul li br meta/;
    my @netscape = qw/center/;

    @ISA = qw(Exporter);
    @EXPORT = (@html2, @netscape);
    %EXPORT_TAGS = (
        'html2' => [@html2],
        'netscape' => [@netscape],
        'standard' => [@EXPORT]
    );
}

=attr DEFAULT_CLASS

To change columns using keywords

    require Text::CGILike;
    Text::CGILike->import(':standard');

    require Term::Size;
    my ($columns) = Term::Size::chars();
    $columns ||= 80;

    my ($TCGI) = Text::CGILike->DEFAULT_CLASS;
    $TCGI->columns($columns);

=cut

my $_DEFAULT_CLASS;

has 'columns' => (
    is => 'rw',
    default => sub { 80 },
);


sub DEFAULT_CLASS {
    return _self_or_default(shift);
}


sub start_html { 
    my ($self, @texts) = _self_or_default(@_);
    my $text;
    if (@texts > 1) {
        my %p = @texts;
        $text = $p{-title} || "";
    } else {
        ($text) = @texts;
    }
    $self->{_start_html} = $text;
    return $self->hr . $self->_center("# "," #", $text) . $self->hr . "\n";
}

sub end_html { 
    my ($self) = _self_or_default(@_);
    my $text = $self->{_start_html} || "END";
    return "\n" . $self->hr . $self->_center("# "," #", $text) . $self->hr;
}

sub meta {
    #no meta in text
    return ""
}

sub h1 {
    my ($self, $title) = _self_or_default(@_);
    return 
    $self->_left("# ", $title) . $self->br();
}

sub hr {
    my ($self) = _self_or_default(@_);

    return "#"x($self->columns)."\n";
}

sub br {
    return "\n";
}

sub center {
    my ($self, $text) = _self_or_default(@_);
    return $self->_center('','', $text);
}

sub ul {
    my ($self, @li) = _self_or_default(@_);
    return join("", grep { defined } @li);
}

sub li {
    my ($self, $li) = _self_or_default(@_);
    my $TF = Text::Format->new({firstIndent => 0, bodyIndent => 2, columns => $self->columns - 2});
    return "- " . $TF->format($li);
}


### PRIVATE ###

sub _self_or_default {
    my ($may_class, @param) = @_;
    if (ref $may_class eq __PACKAGE__) {
        return ($may_class, @param);
    } else {
        $_DEFAULT_CLASS ||= __PACKAGE__->new;
        return ($_DEFAULT_CLASS, $may_class, @param);
    }
}

sub _center {
    my $self = shift;
    my ($left, $right, $text) = @_;
    $left = "" unless defined $left;
    $right = "" unless defined $right;

    my $size = $self->columns - length($left) - length($right);
    my $TF = Text::Format->new({firstIndent => 0, bodyIndent => 0, columns => $size});

    my @texts = $TF->format($text);
    return join("", map {
        $_ = $TF->center($_);
        chomp;
        sprintf($left."%-".$size."s".$right."\n", $_);
    } @texts);

}

sub _left {
    my $self = shift;
    my ($left, $text) = @_;
    $left = "" unless defined $left;

    my $size = $self->columns - length($left);
    my $TF = Text::Format->new({firstIndent => 0, bodyIndent => 0, columns => $size});

    my @texts = $TF->format($text);
    return $left . join("".$left, @texts);

}

1;

__END__

=head1 SEE ALSO

L<CGI>

=head1 BUGS

Any bugs or evolution can be submit here :

L<Github|https://github.com/celogeek/Text-CGILike>

