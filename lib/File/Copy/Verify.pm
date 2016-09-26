package File::Copy::Verify;
use strict;
use warnings;

our $VERSION = '0.1.0';

use File::Copy;
use Path::Tiny;
use Safe::Isa;
use Class::Tiny qw(src dst src_hash dst_hash), {
    hash_algo => 'MD5',
};

sub BUILD {
    my ($self) = @_;

    #coerce src and dst to Path::Tiny object
    if ($self->src->$_isa('Path::Tiny')) {
        $self->src(path($self->src));
    }

    if ($self->dst->$_isa('Path::Tiny')) {
        $self->dst(path($self->dst));
    }
}

sub copy {
    my ($self) = @_;

    if (!$self->$_isa(__PACKAGE__)) {
        my ($src, $dst, $options) = @_;

        return __PACKAGE__->new(
            src => $src,
            dst => $dst,
            %$options
        )->copy();
    }

    if (!defined $self->src_hash) {
        $self->src_hash(
            $self->src->digest($self->hash_algo)
        );
    }

    my $dst = $self->src->copy($self->dst);

    if (!defined $self->dst_hash) {
        $self->dst_hash(
            $dst->digest($self->hash_algo)
        );
    }

    if ( uc $self->src_hash ne uc $self->dst_hash ) {
        die sprintf "Src (%s) hash (%s) and dst (%s) hash (%s) isn't equal",
          $self->src,
          $self->src_hash,
          $dst,
          $self->dst_hash;
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

File::Copy::Verify - It's new $module

=head1 SYNOPSIS

    use File::Copy::Verify;

    verify_copy('a', 'b'); #or copy or cp - all variants are exportable

    #is ekvivalent of

    $verify_copy = File::Copy::Verify->new(
        src => 'a',
        dst => 'b',
    );
    $verify_copy->copy();


    #I know source SHA-256 hash and I can use for validation
    
    File::Copy::Verify::copy('a', 'b', {src_hash => '0'x64, hash_algo => 'SHA-256'});
    
    $verify_copy = File::Copy::Verify->new(
        src       => 'a',
        src_hash  => '0' x 64,
        dst       => 'b',
        hash_algo => 'SHA-256',
    );
    $verify_copy->copy();



=head1 DESCRIPTION

File::Copy::Verify is module for verifiing copy. Some storages (in particular a Net storages) can have troubles with valid copy and C<copy> function from L<File::Copy> don't found this.

This module calculate hash before and after copy and if hash doesn't eqal, then retry mechanism try copy again and again...

=head1 FUNCTIONS

=head2 verify_copy($src, $dst, $options)

=head2 copy

alias for L</verify_copy>

=head2 cp

alias for L</verify_copy>

=head2 verify_move($src, $dst, $options)

same as L</verify_copy> and after success copy unlink source C<$src> file

=head2 move

alias for L</verify_move>

=head2 mv

alias for L</verify_move>

=head2 verify_rcopy

recursive L</verify_copy> 

=head1 METHODS

=head2 new(%attributes)

=head3 %attributes

=head4 src

=head4 dst

=head4 hash_algo

=head4 src_hash

=head4 dst_hash

=head2 copy()

=head2 move()

=head2 rcopy()

=head2 rmove()

=head1 SEE ALSO

L<File::Copy::Vigilant> - Looks really good, don't support other digests - only MD5, don't support hard-set src or dst hash. Don't implement rcopy function. 

L<File::Copy::Reliable> - only "checks that the file size of the copied or moved file is the same as the source".

=head1 LICENSE

Copyright (C) Jan Seidl.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Seidl E<lt>seidl@avast.comE<gt>

=cut
