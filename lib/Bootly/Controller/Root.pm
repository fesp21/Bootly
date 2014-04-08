package Bootly::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

=head1 NAME

Bootly::Controller::Root - Root Controller for Bootly

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $params = $c->req->body_params;
    if ($params->{html} or $params->{css} or $params->{js}) {
      my $snippet_rs = $c->model('BootlyDB::Snippet');
      my $html    = $c->model('BootlyDB::Html')->create({ code => $params->{html} });
      my $css     = $c->model('BootlyDB::Css')->create({ code => $params->{css} });
      my $js      = $c->model('BootlyDB::Javascript')->create({ code => $params->{js} });
      my $id;
      my @chars = ('a'..'z', '0'..'9', 'A'..'Z');
      $id .= $chars[rand($#chars)] for (0..8);
      my $snippet = $snippet_rs->create({
        snippet_id => $id,
        html       => $html->id,
        javascript => $js->id,
        css        => $css->id,
      });
      
      my $uri = $c->req->uri . "${id}";
      $c->flash->{success_msg} = "Successfully created snippet ${uri}";
      $c->res->redirect($uri);
      $c->detach;
    }
}

sub default :Path {
    my ( $self, $c ) = @_;
    my $id = $c->req->path;
    if (my $snippet = $c->model('BootlyDB::Snippet')->find({ snippet_id => $id })) {
        $c->stash(
            snippet => $snippet,
        );
    }
    else {
      $c->res->redirect('/');
      $c->detach;
    }
    
    $c->stash->{template} = 'index.html';
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Brad,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
__END__