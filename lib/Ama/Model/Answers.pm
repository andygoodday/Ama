package Ama::Model::Answers;
use Mojo::Base -base;

has 'pg';
has 'username';

sub mark {
  my ($self, $comment_id, $question_id) = @_;
  my $results = eval {
    my $tx = $self->pg->db->begin;
    $self->unmark($comment_id, $question_id);
    #my $sql = 'insert into answers (comment_id, question_id, username) select ?, ?, username from questions where question_id = ? and username = ? returning *';
    my $sql = 'insert into answers (comment_id, question_id, username) values (?, ?, ?) returning *';
    #my $results = $self->pg->db->query($sql, $comment_id, $question_id, $question_id, $self->username)->hash;
    my $results = $self->pg->db->query($sql, $comment_id, $question_id, $self->username)->hash;
    $tx->commit;
    $results;
  };
  $@ ? { error => $@ } : $results;
}

sub unmark {
  my ($self, $comment_id, $question_id) = @_;
  my $results = eval {
    my $sql = 'delete from answers where comment_id = ? and question_id = ? and exists (select username from questions where question_id = ? and username = ?) returning *';
    $self->pg->db->query($sql, $comment_id, $question_id, $question_id, $self->username)->hash;
  };
  $@ ? { error => $@ } : $results;
}

1;
