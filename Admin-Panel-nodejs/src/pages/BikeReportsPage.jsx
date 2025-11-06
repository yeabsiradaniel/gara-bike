import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogTitle, Button, Checkbox, FormControlLabel } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';

const BikeReportsPage = () => {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [reportToDelete, setReportToDelete] = useState(null);
  const [formDialogOpen, setFormDialogOpen] = useState(false);
  const [currentReport, setCurrentReport] = useState(null);

  const fetchBikeReports = () => {
    setLoading(true);
    dataService.getAll('bikereports')
      .then(response => {
        setReports(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch bike reports:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchBikeReports();
  }, []);

  const handleOpenFormDialog = (report) => {
    setCurrentReport({ ...report });
    setFormDialogOpen(true);
  };

  const handleCloseFormDialog = () => {
    setFormDialogOpen(false);
    setCurrentReport(null);
  };

  const handleSave = async () => {
    try {
      await dataService.update('bikereports', currentReport.id, { isResolved: currentReport.isResolved });
      fetchBikeReports();
      handleCloseFormDialog();
    } catch (error) {
      console.error("Failed to save bike report:", error);
    }
  };

  const handleDeleteClick = (id) => {
    setReportToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('bikereports', reportToDelete);
      fetchBikeReports();
      setDeleteDialogOpen(false);
      setReportToDelete(null);
    } catch (error) {
      console.error("Failed to delete bike report:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'Report ID', width: 220 },
    { field: 'bike', headerName: 'Bike QR', width: 220, valueGetter: (value) => value.qr_code },
    { field: 'user', headerName: 'User Email', width: 220, valueGetter: (value) => value.email },
    { field: 'reportType', headerName: 'Report Type', width: 150 },
    { field: 'comments', headerName: 'Comments', width: 250 },
    { field: 'isResolved', headerName: 'Resolved', type: 'boolean', width: 120 },
    { field: 'createdAt', headerName: 'Created At', type: 'dateTime', width: 180, valueGetter: (value) => new Date(value) },
    {
      field: 'actions',
      headerName: 'Actions',
      type: 'actions',
      width: 120,
      getActions: ({ id, row }) => [
        <IconButton color="primary" onClick={() => handleOpenFormDialog(row)}><EditIcon /></IconButton>,
        <IconButton color="error" onClick={() => handleDeleteClick(id)}><DeleteIcon /></IconButton>,
      ],
    },
  ];

  return (
    <Box sx={{ height: '85vh', width: '100%' }}>
      <Typography variant="h4" sx={{ mb: 4 }}>Manage Bike Reports</Typography>
      <DataGrid
        rows={reports}
        columns={columns}
        loading={loading}
        getRowId={(row) => row.id}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 10 },
          },
        }}
        pageSizeOptions={[5, 10, 20]}
        checkboxSelection
      />
      <Dialog open={deleteDialogOpen} onClose={handleCloseFormDialog}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent><p>Are you sure you want to delete this bike report?</p></DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={formDialogOpen} onClose={handleCloseFormDialog}>
        <DialogTitle>Edit Bike Report</DialogTitle>
        <DialogContent>
            {currentReport && (
                <Box component="form" sx={{ mt: 2, minWidth: 300 }}>
                    <FormControlLabel control={<Checkbox checked={currentReport.isResolved} onChange={(e) => setCurrentReport({ ...currentReport, isResolved: e.target.checked })} />} label="Resolved" />
                </Box>
            )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseFormDialog}>Cancel</Button>
          <Button onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default BikeReportsPage;